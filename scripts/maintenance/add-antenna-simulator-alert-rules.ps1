$ErrorActionPreference = 'Stop'

# Adds five Grafana-managed alert rules for the antenna simulator by using the Grafana Alerting Provisioning HTTP API.
# Safe behavior:
# - reads the local Grafana admin password from secrets/grafana_admin_password.txt
# - uses the existing "Prometheus Target Down" alert as a template
# - skips alert rules that already exist
# - exports the created antenna alert rule group as YAML into monitoring/grafana/exports
# - does not print the Grafana password

$GrafanaUrl = "http://localhost:3000"
$AdminUser = "admin"
$ReceiverName = "local-webhook-receiver"
$TemplateRuleTitle = "Prometheus Target Down"
$RuleGroupName = "antenna-monitoring"

$ScriptPath = $MyInvocation.MyCommand.Path
$ScriptDir = Split-Path -Parent $ScriptPath
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)

if (-not (Test-Path (Join-Path $ProjectRoot "secrets\grafana_admin_password.txt"))) {
    $ProjectRoot = Get-Location
}

$PasswordPath = Join-Path $ProjectRoot "secrets\grafana_admin_password.txt"
$ExportDir = Join-Path $ProjectRoot "monitoring\grafana\exports"
$ExportPath = Join-Path $ExportDir "antenna-simulator-alert-rules.yaml"

if (-not (Test-Path $PasswordPath)) {
    throw "Grafana password file not found: $PasswordPath"
}

New-Item -ItemType Directory -Force -Path $ExportDir | Out-Null

$Password = (Get-Content -Raw -Path $PasswordPath).Trim()
if ([string]::IsNullOrWhiteSpace($Password)) {
    throw "Grafana password file is empty: $PasswordPath"
}

$AuthPlain = "${AdminUser}:$Password"
$AuthBytes = [System.Text.Encoding]::UTF8.GetBytes($AuthPlain)
$AuthBase64 = [Convert]::ToBase64String($AuthBytes)

$Headers = @{
    "Authorization" = "Basic $AuthBase64"
    "Accept" = "application/json"
    "Content-Type" = "application/json"
    "X-Disable-Provenance" = "true"
}

function Invoke-GrafanaGetJson {
    param([string]$Path)
    $Uri = "$GrafanaUrl$Path"
    return Invoke-RestMethod -Method Get -Uri $Uri -Headers $Headers
}

function Invoke-GrafanaPostJson {
    param(
        [string]$Path,
        [object]$Body
    )
    $Uri = "$GrafanaUrl$Path"
    $Json = $Body | ConvertTo-Json -Depth 100
    return Invoke-RestMethod -Method Post -Uri $Uri -Headers $Headers -Body $Json
}

function Copy-JsonObject {
    param([object]$Object)
    return ($Object | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Set-PrometheusExpression {
    param(
        [object[]]$Data,
        [string]$Expression
    )

    $QueryEntry = $null

    foreach ($entry in $Data) {
        if ($null -ne $entry.model -and $entry.model.PSObject.Properties.Name -contains "expr") {
            if ($entry.datasourceUid -ne "__expr__" -and $entry.datasourceUid -ne "-100") {
                $QueryEntry = $entry
                break
            }
        }
    }

    if ($null -eq $QueryEntry) {
        throw "Could not find Prometheus query entry in template alert rule data."
    }

    $QueryEntry.model.expr = $Expression
    $QueryEntry.model.refId = "A"
    $QueryEntry.refId = "A"

    return $Data
}

Write-Host "Checking Grafana API health..."
$Health = Invoke-GrafanaGetJson "/api/health"
Write-Host "OK: Grafana API reachable. Version: $($Health.version)"

Write-Host "Loading existing alert rules..."
$ExistingRules = Invoke-GrafanaGetJson "/api/v1/provisioning/alert-rules"

$TemplateRule = $ExistingRules | Where-Object { $_.title -eq $TemplateRuleTitle } | Select-Object -First 1

if ($null -eq $TemplateRule) {
    throw "Template rule not found: $TemplateRuleTitle. Create or keep the existing Prometheus Target Down alert first."
}

if ([string]::IsNullOrWhiteSpace($TemplateRule.folderUID)) {
    throw "Template rule has no folderUID. Cannot place new antenna rules in the same Grafana folder."
}

Write-Host "OK: Template rule found: $($TemplateRule.title)"
Write-Host "Using folderUID: $($TemplateRule.folderUID)"
Write-Host "Using contact point receiver: $ReceiverName"
Write-Host "Using rule group: $RuleGroupName"

$AlertSpecs = @(
    @{
        Uid = "antenna-no-packets"
        Title = "Antenna No Packets"
        Expr = "sum(antenna_online{job=`"antenna-simulator`"} == bool 0)"
        Summary = "Antenna stopped sending packets"
        Description = "No packets are arriving from the simulated antenna. Possible causes: power loss, mobile network outage, SIM/provider problem, damaged antenna, or device offline."
        Severity = "critical"
    },
    @{
        Uid = "antenna-weak-signal"
        Title = "Antenna Weak Signal"
        Expr = "sum(antenna_signal_strength_dbm{job=`"antenna-simulator`"} < bool -100)"
        Summary = "Antenna mobile signal is weak"
        Description = "The simulated antenna signal strength is below -100 dBm. Possible causes: poor location, weather, antenna placement, mobile provider or SIM issue."
        Severity = "warning"
    },
    @{
        Uid = "antenna-low-battery"
        Title = "Antenna Low Battery"
        Expr = "sum(antenna_battery_percent{job=`"antenna-simulator`"} < bool 20)"
        Summary = "Antenna battery is low"
        Description = "The simulated antenna battery level is below 20 percent. A maintenance visit or battery replacement may be required."
        Severity = "warning"
    },
    @{
        Uid = "antenna-high-packet-delay"
        Title = "Antenna High Packet Delay"
        Expr = "sum(antenna_packet_delay_seconds{job=`"antenna-simulator`"} > bool 10)"
        Summary = "Antenna packets are delayed"
        Description = "Packet delivery delay is above 10 seconds. Possible causes: poor mobile network quality, overloaded gateway, queue backlog, or slow processing."
        Severity = "warning"
    },
    @{
        Uid = "antenna-many-errors"
        Title = "Antenna Many Errors"
        Expr = "(sum(increase(antenna_errors_total{job=`"antenna-simulator`"}[2m])) or vector(0)) > bool 5"
        Summary = "Antenna error rate is high"
        Description = "More than five simulated errors occurred within two minutes. Possible causes: firmware issue, API change, invalid data format, sensor fault, or transmission problem."
        Severity = "warning"
    }
)

$Created = @()
$Skipped = @()

foreach ($Spec in $AlertSpecs) {
    $AlreadyExists = $ExistingRules | Where-Object { $_.uid -eq $Spec.Uid -or $_.title -eq $Spec.Title } | Select-Object -First 1

    if ($null -ne $AlreadyExists) {
        Write-Host "SKIP: Alert already exists: $($Spec.Title)"
        $Skipped += $Spec.Title
        continue
    }

    $DataCopy = Copy-JsonObject $TemplateRule.data
    $DataCopy = Set-PrometheusExpression -Data $DataCopy -Expression $Spec.Expr

    $Body = [ordered]@{
        uid = $Spec.Uid
        title = $Spec.Title
        ruleGroup = $RuleGroupName
        folderUID = $TemplateRule.folderUID
        orgId = 1
        condition = $TemplateRule.condition
        data = $DataCopy
        noDataState = "OK"
        execErrState = "Error"
        "for" = "1m"
        keepFiringFor = "0s"
        annotations = [ordered]@{
            summary = $Spec.Summary
            description = $Spec.Description
        }
        labels = [ordered]@{
            component = "antenna-simulator"
            severity = $Spec.Severity
            lab = "grafana-monitoring"
        }
        isPaused = $false
        notification_settings = [ordered]@{
            receiver = $ReceiverName
        }
    }

    Write-Host "CREATE: $($Spec.Title)"
    $Result = Invoke-GrafanaPostJson "/api/v1/provisioning/alert-rules" $Body
    $Created += $Spec.Title
}

Write-Host ""
Write-Host "Created alert rules:"
if ($Created.Count -eq 0) {
    Write-Host "  none"
} else {
    foreach ($name in $Created) { Write-Host "  - $name" }
}

Write-Host ""
Write-Host "Skipped alert rules:"
if ($Skipped.Count -eq 0) {
    Write-Host "  none"
} else {
    foreach ($name in $Skipped) { Write-Host "  - $name" }
}

Write-Host ""
Write-Host "Exporting antenna alert rule group as YAML..."

$FolderUidEscaped = [System.Uri]::EscapeDataString($TemplateRule.folderUID)
$GroupEscaped = [System.Uri]::EscapeDataString($RuleGroupName)
$ExportUri = "$GrafanaUrl/api/v1/provisioning/folder/$FolderUidEscaped/rule-groups/$GroupEscaped/export?format=yaml"

$ExportHeaders = @{
    "Authorization" = "Basic $AuthBase64"
    "Accept" = "application/yaml"
    "X-Disable-Provenance" = "true"
}

$Response = Invoke-WebRequest -UseBasicParsing -Method Get -Uri $ExportUri -Headers $ExportHeaders
$Response.Content | Set-Content -Path $ExportPath -Encoding UTF8

Write-Host "OK: Exported antenna alert rules to:"
Write-Host "  $ExportPath"

Write-Host ""
Write-Host "Next checks:"
Write-Host "  Select-String -Path `"$ExportPath`" -Pattern `"password|token|secret|authorization|basic`" -CaseSensitive:`$false"
Write-Host "  git status --short"


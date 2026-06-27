# NMEA Wind + Depth UDP sender
# Bezi vedla nmeasim a posiela MWV (vietor) a DBT (hlbka) na mobil
# Pouzitie: .\nmea_extras_sender.ps1 [-TargetIP 192.168.31.160] [-Port 10110]
#            [-WindAngle 45] [-WindSpeed 12.5] [-Depth 15.5]

param(
    [string]$TargetIP  = "192.168.31.160",
    [int]   $Port      = 10110,
    [double]$WindAngle = 15.0,   # stupne apparent (0-359)
    [double]$WindSpeed = 9.0,   # uzly
    [double]$Depth     = 45.0    # metre
)

function Get-NmeaChecksum([string]$body) {
    $cs = 0
    foreach ($c in $body.ToCharArray()) { $cs = $cs -bxor [byte][char]$c }
    return $cs.ToString("X2")
}

function Send-Nmea([System.Net.Sockets.UdpClient]$udp, [string]$body) {
    $cs   = Get-NmeaChecksum $body
    $line = "`$$body*$cs`r`n"
    $b    = [System.Text.Encoding]::ASCII.GetBytes($line)
    $udp.Send($b, $b.Length) | Out-Null
}

$udp = New-Object System.Net.Sockets.UdpClient
$udp.Connect($TargetIP, $Port)

Write-Host "Posielam NMEA vietor + hlbka -> $TargetIP`:$Port"
Write-Host "  TWA = $WindAngle deg  TWS = $WindSpeed kn  DEPTH = $Depth m"
Write-Host "Uprav hodnoty v skripte alebo cez parametre. Ctrl+C zastavi."
Write-Host ""

$inv = [System.Globalization.CultureInfo]::InvariantCulture

while ($true) {
    # MWV — Wind Speed and Angle (apparent)
    $wa  = $WindAngle.ToString("000.0", $inv)
    $ws  = $WindSpeed.ToString("00.0", $inv)
    $mwv = "IIMWV,$wa,R,$ws,N,A"
    Send-Nmea $udp $mwv

    # DBT — Depth Below Transducer
    $feet   = $Depth * 3.28084
    $fathom = $Depth * 0.546807
    $df = $feet.ToString("0.0", $inv)
    $dm = $Depth.ToString("0.0", $inv)
    $dfa = $fathom.ToString("0.0", $inv)
    $dbt = "IIDBT,$df,f,$dm,M,$dfa,F"
    Send-Nmea $udp $dbt

    Write-Host "." -NoNewline
    Start-Sleep -Milliseconds 1000
}

$udp.Close()

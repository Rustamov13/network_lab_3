# ping-sites.ps1
# Pings a list of websites, logs their resolved IP and average response time to a CSV file.

# List of websites to ping
$sites = @(
    "google.com",
    "microsoft.com",
    "github.com",
    "stackoverflow.com",
    "reddit.com"
)

# Array to hold results
$results = @()

foreach ($site in $sites) {
    try {
        # Resolve the first IP address
        $ip = ([System.Net.Dns]::GetHostAddresses($site) | Where-Object { $_.AddressFamily -eq 'InterNetwork' })[0].IPAddressToString
    } catch {
        $ip = "Resolution Failed"
    }

    try {
        # Ping 4 times and compute the average response time
        $pings = Test-Connection -ComputerName $site -Count 4 -ErrorAction Stop
        $avgTime = ($pings | Measure-Object -Property ResponseTime -Average).Average
    } catch {
        $avgTime = $null
    }

    # Create result object
    $results += [PSCustomObject]@{
        Website          = $site
        IPAddress        = $ip
        AveragePing_ms   = if ($avgTime) { "{0:N2}" -f $avgTime } else { "Timeout/Failed" }
    }
}

# Export results to CSV
$csvPath = "ping_results.csv"
$results | Export-Csv -Path $csvPath -NoTypeInformation

Write-Host "Ping results saved to $csvPath"

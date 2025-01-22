# Netzwerk-Diagnose-Tool
# Dieses Skript führt grundlegende Netzwerkdiagnosen durch und zeigt die Ergebnisse übersichtlich an.

# GUI erstellen
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Fenster erstellen
$form = New-Object System.Windows.Forms.Form
$form.Text = "Netzwerk-Diagnose-Tool"
$form.Size = New-Object System.Drawing.Size(400, 400)
$form.StartPosition = "CenterScreen"

# Textfeld für Eingabe
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Size = New-Object System.Drawing.Size(200, 20)
$textBox.Location = New-Object System.Drawing.Point(100, 50)
$textBox.Text = "Hostname oder IP-Adresse"
$textBox.ForeColor = [System.Drawing.Color]::Gray
$form.Controls.Add($textBox)

# Placeholder simulieren
$textBox.Add_GotFocus({
    if ($textBox.Text -eq "Hostname oder IP-Adresse") {
        $textBox.Text = ""
        $textBox.ForeColor = [System.Drawing.Color]::Black
    }
})

$textBox.Add_LostFocus({
    if ([string]::IsNullOrWhiteSpace($textBox.Text)) {
        $textBox.Text = "Hostname oder IP-Adresse"
        $textBox.ForeColor = [System.Drawing.Color]::Gray
    }
})

# Buttons erstellen
$pingButton = New-Object System.Windows.Forms.Button
$pingButton.Text = "Ping"
$pingButton.Location = New-Object System.Drawing.Point(100, 100)
$form.Controls.Add($pingButton)

$dnsButton = New-Object System.Windows.Forms.Button
$dnsButton.Text = "DNS-Abfrage"
$dnsButton.Location = New-Object System.Drawing.Point(200, 100)
$form.Controls.Add($dnsButton)

$exportButton = New-Object System.Windows.Forms.Button
$exportButton.Text = "Bericht speichern"
$exportButton.Location = New-Object System.Drawing.Point(100, 140)
$form.Controls.Add($exportButton)

# Ergebnisfeld
$resultBox = New-Object System.Windows.Forms.TextBox
$resultBox.Size = New-Object System.Drawing.Size(300, 150)
$resultBox.Location = New-Object System.Drawing.Point(50, 200)
$resultBox.Multiline = $true
$resultBox.ScrollBars = "Vertical"
$form.Controls.Add($resultBox)

# Funktionen
$pingButton.Add_Click({
    $inputHost = $textBox.Text
    if (-not [string]::IsNullOrWhiteSpace($inputHost) -and $inputHost -ne "Hostname oder IP-Adresse") {
        try {
            $pingResult = Test-Connection -ComputerName $inputHost -Count 4 -ErrorAction SilentlyContinue
            if ($pingResult) {
                $resultBox.Text = "Ping erfolgreich:\n" + ($pingResult | Select-Object Address, ResponseTime | Out-String)
            } else {
                $resultBox.Text = "Ping fehlgeschlagen."
            }
        } catch {
            $resultBox.Text = "Fehler beim Ping-Test."
        }
    } else {
        $resultBox.Text = "Bitte eine gültige IP-Adresse oder einen Hostnamen eingeben."
    }
})

$dnsButton.Add_Click({
    $inputHost = $textBox.Text
    if (-not [string]::IsNullOrWhiteSpace($inputHost) -and $inputHost -ne "Hostname oder IP-Adresse") {
        try {
            $dnsResult = [System.Net.Dns]::GetHostAddresses($inputHost)
            $resultBox.Text = "DNS-Auflösung erfolgreich:\n" + ($dnsResult | Out-String)
        } catch {
            $resultBox.Text = "DNS-Auflösung fehlgeschlagen."
        }
    } else {
        $resultBox.Text = "Bitte eine gültige IP-Adresse oder einen Hostnamen eingeben."
    }
})

$exportButton.Add_Click({
    try {
        $filePath = "$env:USERPROFILE\NetzwerkDiagnoseErgebnisse.txt"
        $resultBox.Lines | Out-File -FilePath $filePath -Encoding UTF8
        [System.Windows.Forms.MessageBox]::Show("Bericht gespeichert unter: $filePath", "Erfolg")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Fehler beim Speichern des Berichts.", "Fehler")
    }
})

# Formular anzeigen
[void]$form.ShowDialog()
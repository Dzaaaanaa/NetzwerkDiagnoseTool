# Netzwerk-Diagnose-Tool
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# GUI erstellen
$form = New-Object System.Windows.Forms.Form
$form.Text = "Netzwerk-Diagnose-Tool"
$form.Size = New-Object System.Drawing.Size(800, 800)
$form.StartPosition = "CenterScreen"

# Textfeld für Eingabe
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Size = New-Object System.Drawing.Size(600, 50)
$textBox.Font = New-Object System.Drawing.Font("Arial", 16)
$textBox.Location = New-Object System.Drawing.Point(100, 30)
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

# Panel für Buttons
$buttonPanel = New-Object System.Windows.Forms.Panel
$buttonPanel.Size = New-Object System.Drawing.Size(700, 150)
$buttonPanel.Location = New-Object System.Drawing.Point(50, 100)
$form.Controls.Add($buttonPanel)

# Buttons erstellen
$pingButton = New-Object System.Windows.Forms.Button
$pingButton.Text = "Ping"
$pingButton.Size = New-Object System.Drawing.Size(150, 100)
$pingButton.Font = New-Object System.Drawing.Font("Arial", 10)
$pingButton.Location = New-Object System.Drawing.Point(10, 10)
$buttonPanel.Controls.Add($pingButton)

$dnsButton = New-Object System.Windows.Forms.Button
$dnsButton.Text = "DNS-Abfrage"
$dnsButton.Size = New-Object System.Drawing.Size(150, 100)
$dnsButton.Font = New-Object System.Drawing.Font("Arial", 10)
$dnsButton.Location = New-Object System.Drawing.Point(180, 10)
$buttonPanel.Controls.Add($dnsButton)

$exportButton = New-Object System.Windows.Forms.Button
$exportButton.Text = "Bericht"
$exportButton.Size = New-Object System.Drawing.Size(150, 100)
$exportButton.Font = New-Object System.Drawing.Font("Arial", 10)
$exportButton.Location = New-Object System.Drawing.Point(350, 10)
$buttonPanel.Controls.Add($exportButton)

$helpButton = New-Object System.Windows.Forms.Button
$helpButton.Text = "Hilfe"
$helpButton.Size = New-Object System.Drawing.Size(150, 100)
$helpButton.Font = New-Object System.Drawing.Font("Arial", 10)
$helpButton.Location = New-Object System.Drawing.Point(520, 10)
$buttonPanel.Controls.Add($helpButton)

# Icons hinzufügen
$pingIcon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Command ping.exe).Path)
$dnsIcon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Command nslookup.exe).Path)
$reportIcon = [System.Drawing.SystemIcons]::Information.ToBitmap()
$helpIcon = [System.Drawing.SystemIcons]::Question.ToBitmap()

$pingButton.Image = $pingIcon.ToBitmap()
$pingButton.ImageAlign = "TopCenter"
$pingButton.TextAlign = "BottomCenter"

$dnsButton.Image = $dnsIcon.ToBitmap()
$dnsButton.ImageAlign = "TopCenter"
$dnsButton.TextAlign = "BottomCenter"

$exportButton.Image = $reportIcon
$exportButton.ImageAlign = "TopCenter"
$exportButton.TextAlign = "BottomCenter"

$helpButton.Image = $helpIcon
$helpButton.ImageAlign = "TopCenter"
$helpButton.TextAlign = "BottomCenter"

# Ergebnisfeld
$resultBox = New-Object System.Windows.Forms.TextBox
$resultBox.Size = New-Object System.Drawing.Size(700, 400)
$resultBox.Font = New-Object System.Drawing.Font("Arial", 16)
$resultBox.Location = New-Object System.Drawing.Point(50, 300)
$resultBox.Multiline = $true
$resultBox.ScrollBars = "Vertical"
$form.Controls.Add($resultBox)

# Tooltips hinzufügen
$tooltip = New-Object System.Windows.Forms.ToolTip
$tooltip.SetToolTip($pingButton, "Führt einen Ping-Test durch")
$tooltip.SetToolTip($dnsButton, "Führt eine DNS-Abfrage durch")
$tooltip.SetToolTip($exportButton, "Speichert die Ergebnisse als Bericht")
$tooltip.SetToolTip($helpButton, "Zeigt die Hilfe an")
$tooltip.SetToolTip($textBox, "Geben Sie eine IP-Adresse oder einen Hostnamen ein")

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

$helpButton.Add_Click({
    [System.Windows.Forms.MessageBox]::Show("Anleitung:\n1. Geben Sie einen Hostnamen oder eine IP-Adresse ein.\n2. Wählen Sie 'Ping' für einen Erreichbarkeitstest oder 'DNS-Abfrage', um die IP zu lösen.\n3. Speichern Sie Ergebnisse mit 'Bericht'.", "Hilfe")
})

# Formular anzeigen
[void]$form.ShowDialog()
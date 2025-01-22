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

# Funktion zum Erstellen von Buttons aus einer Range
function CreateButtonsFromRange {
    param (
        [System.Windows.Forms.Panel]$panel, # Das Panel, zu dem die Buttons hinzugefügt werden
        [array]$buttonData                 # Array mit Button-Texten und Icons
    )
    
    $buttonWidth = [Math]::Floor(($panel.Width / $buttonData.Count)) - 10
    $buttonHeight = 100

    1..$buttonData.Count | ForEach-Object {
        $index = $_ - 1
        $button = New-Object System.Windows.Forms.Button
        $button.Text = $buttonData[$index].Text
        $button.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
        $button.Location = New-Object System.Drawing.Point(($index * ($buttonWidth + 10)), 10)
        $button.Font = New-Object System.Drawing.Font("Arial", 10)
        $button.Image = $buttonData[$index].Icon.ToBitmap()
        $button.ImageAlign = "TopCenter"
        $button.TextAlign = "BottomCenter"
        $panel.Controls.Add($button)

        # Event-Zuweisung basierend auf Button-Typ
        switch ($button.Text) {
            "Ping" {
                $button.Add_Click({
                    $inputHost = $textBox.Text
                    if (-not [string]::IsNullOrWhiteSpace($inputHost) -and $inputHost -ne "Hostname oder IP-Adresse") {
                        try {
                            $pingResult = Test-Connection -ComputerName $inputHost -Count 4 -ErrorAction SilentlyContinue
                            if ($pingResult) {
                                $resultBox.Text = "Ping erfolgreich`n" + ($pingResult | Select-Object Address, ResponseTime | Out-String)
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
            }
            "DNS-Abfrage" {
                $button.Add_Click({
                    $inputHost = $textBox.Text
                    if (-not [string]::IsNullOrWhiteSpace($inputHost) -and $inputHost -ne "Hostname oder IP-Adresse") {
                        try {
                            $dnsResult = [System.Net.Dns]::GetHostAddresses($inputHost)
                            $resultBox.Text = "DNS-Auflösung erfolgreich`n" + ($dnsResult | Out-String)
                        } catch {
                            $resultBox.Text = "DNS-Auflösung fehlgeschlagen."
                        }
                    } else {
                        $resultBox.Text = "Bitte eine gültige IP-Adresse oder einen Hostnamen eingeben."
                    }
                })
            }
            "Bericht" {
                $button.Add_Click({
                    if ([string]::IsNullOrWhiteSpace($resultBox.Text)) {
                        [System.Windows.Forms.MessageBox]::Show("Keine Ergebnisse zum Anzeigen oder Speichern.", "Fehler")
                    } else {
                        $currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                        $reportText = "Bericht erstellt am $currentTime`n`n" + $resultBox.Text
                        $resultBox.Text = $reportText

                        $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
                        $saveFileDialog.Filter = "Textdateien (*.txt)|*.txt"
                        $saveFileDialog.Title = "Bericht speichern"
                        if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                            $filePath = $saveFileDialog.FileName
                            Set-Content -Path $filePath -Value $reportText
                            [System.Windows.Forms.MessageBox]::Show("Bericht gespeichert unter: $filePath", "Erfolg")
                        }
                    }
                })
            }
            "Hilfe" {
                $button.Add_Click({
                    [System.Windows.Forms.MessageBox]::Show("Geben Sie einen Hostnamen oder eine IP-Adresse ein. Wählen Sie 'Ping' für einen Erreichbarkeitstest oder 'DNS-Abfrage', um die IP zu lösen. Ergebnisse werden direkt im Fenster angezeigt. Speichern Sie Ergebnisse mit 'Bericht'.", "Hilfe")
                })
            }
        }
    }
}

# Button-Daten
$buttonData = @(
    @{ Text = "Ping"; Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Command ping.exe).Path) },
    @{ Text = "DNS-Abfrage"; Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Command nslookup.exe).Path) },
    @{ Text = "Bericht"; Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Command notepad.exe).Path) },
    @{ Text = "Hilfe"; Icon = [System.Drawing.SystemIcons]::Information }
)

# Buttons mit der Funktion erstellen
CreateButtonsFromRange -panel $buttonPanel -buttonData $buttonData

# Ergebnisfeld
$resultBox = New-Object System.Windows.Forms.TextBox
$resultBox.Size = New-Object System.Drawing.Size(700, 300)
$resultBox.Font = New-Object System.Drawing.Font("Arial", 16)
$resultBox.Location = New-Object System.Drawing.Point(50, 300)
$resultBox.Multiline = $true
$resultBox.ScrollBars = "Vertical"
$form.Controls.Add($resultBox)

# Farbauswahl-Button hinzufügen (unten rechts)
$colorButton = New-Object System.Windows.Forms.Button
$colorButton.Text = "Farbauswahl"
$colorButton.Size = New-Object System.Drawing.Size(150, 50)
$colorButton.Font = New-Object System.Drawing.Font("Arial", 10)
$colorButton.Location = New-Object System.Drawing.Point(($form.ClientSize.Width - 200), ($form.ClientSize.Height - 120))
$colorButton.Anchor = "Bottom, Right"
$form.Controls.Add($colorButton)

# ColorDialog hinzufügen
$colorDialog = New-Object System.Windows.Forms.ColorDialog
$colorButton.Add_Click({
    if ($colorDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $form.BackColor = $colorDialog.Color
    }
})

# Formular anzeigen
[void]$form.ShowDialog()
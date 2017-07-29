Imports System.IO

Public Class main
    Public wowdir As String

    Private Sub add_Click(sender As Object, e As EventArgs) Handles add.Click
        Dim key As String

        ' Make sure key is defined to avoid potential errors
        key = ""

        ' Modifier down
        If control.Checked Then
            key = key + "{CTRLDOWN}"
        End If
        If shift.Checked Then
            key = key + "{SHIFTDOWN}"
        End If
        If alt.Checked Then
            key = key + "{ALTDOWN}"
        End If

        ' Set the actual button.
        If fkey.Checked Then
            key = key + "{F" + button.Text + "}"
        ElseIf numpad.Checked Then
            key = key + "{Numpad" + button.Text + "}"
        Else
            key = key + button.Text
        End If

        ' Modifier up
        If alt.Checked Then
            key = key + "{ALTUP}"
        End If
        If shift.Checked Then
            key = key + "{SHIFTUP}"
        End If
        If control.Checked Then
            key = key + "{CTRLUP}"
        End If

        ' Add to database
        Try
            ahk.Rows.Add(skillname.SelectedItem.ToString, key, pixelcolor.Text)
        Catch ex As Exception
            MsgBox("Spell name '" + skillname.Text + "' is already in the table, please remove it before adding it again.")
        End Try

        ' Purge
        button.Text = ""
        pixelcolor.Text = ""
        add.Enabled = False

        If ahk.Rows.Count Then
            savexml.Enabled = True
        Else
            savexml.Enabled = False
        End If

        Me.DataGridView1.FirstDisplayedScrollingRowIndex = Me.DataGridView1.RowCount - 1
    End Sub

    Private Sub main_Load(sender As Object, e As EventArgs) Handles MyBase.Load
findwowagain:
        wowdir = My.Settings.wowloc

        If wowdir = Nothing Or Not My.Computer.FileSystem.FileExists(wowdir + "Wow.exe") Then
            Dim dlgResult As DialogResult = findwow.ShowDialog()

            If dlgResult = Windows.Forms.DialogResult.OK Then
                wowdir = findwow.SelectedPath
                wowdir = wowdir + "\"
                If Not My.Computer.FileSystem.FileExists(wowdir + "Wow.exe") Then
                    MsgBox("World of Warcraft could not be found in the selected folder, please try another.")
                    GoTo findwowagain
                End If
                My.Settings.wowloc = wowdir
                My.Settings.Save()
            End If
        End If

        Dim folders As New DirectoryInfo(wowdir.ToString + "interface\addons\Xeltors_Ovale_Scripts\class")

        Dim dirs = From dir In folders.EnumerateDirectories()

        playerclass.Items.Clear()
        For Each di As DirectoryInfo In dirs
            If di.Name.ToString <> "tools" Then
                playerclass.Items.Add(di.Name.ToString)
            End If
        Next

        ycoord.Text = My.Settings.ycoord
        xcoord.Text = My.Settings.xcoord

        If ahk.Rows.Count Then
            savexml.Enabled = True
        Else
            savexml.Enabled = False
        End If
    End Sub

    Private Sub button_TextChanged(sender As Object, e As EventArgs) Handles button.TextChanged
        If button.Text <> "" And pixelcolor.Text <> "" And skillname.SelectedItem.ToString <> "" Then
            add.Enabled = True
        Else
            add.Enabled = False
        End If
    End Sub

    Private Sub pixelcolor_TextChanged(sender As Object, e As EventArgs) Handles pixelcolor.TextChanged
        If button.Text <> "" And pixelcolor.Text <> "" And skillname.SelectedItem.ToString <> "" Then
            add.Enabled = True
        Else
            add.Enabled = False
        End If
    End Sub

    Private Sub skillname_SelectedIndexChanged(sender As Object, e As EventArgs) Handles skillname.SelectedIndexChanged
        If skillname.SelectedItem.ToString <> "" Then
            button.Enabled = True
            pixelcolor.Enabled = True
        End If
        If button.Text <> "" And pixelcolor.Text <> "" And skillname.SelectedItem.ToString <> "" Then
            add.Enabled = True
        Else
            add.Enabled = False
        End If
    End Sub

    Private Sub pixelcolor_Clicked(sender As Object, e As EventArgs) Handles pixelcolor.DoubleClick
        If Clipboard.ContainsText And Clipboard.GetText.ToString.Contains("0x") Then
            pixelcolor.Text = Clipboard.GetText.ToString
            Clipboard.Clear()
        Else
            Dim p As New Process

            p.StartInfo.UseShellExecute = False
            p.StartInfo.FileName = "auto_pixelfind.exe"
            p.StartInfo.Arguments = xcoord.ToString + " " + ycoord.ToString

            p.Start()
            p.WaitForExit()

            pixelcolor.Text = Clipboard.GetText.ToString
            Clipboard.Clear()
        End If
    End Sub

    Private Sub savexml_Click(sender As Object, e As EventArgs) Handles savexml.Click
        Dim saveFileDialog1 As New SaveFileDialog()

        saveFileDialog1.Filter = "xml files (*.xml)|*.xml"
        saveFileDialog1.FilterIndex = 2
        saveFileDialog1.RestoreDirectory = True

        If saveFileDialog1.ShowDialog() = DialogResult.OK Then
            ahk.WriteXml(saveFileDialog1.FileName)
            MsgBox("File saved to: " + saveFileDialog1.FileName)
        End If
    End Sub

    Private Sub loadxml_Click(sender As Object, e As EventArgs) Handles loadxml.Click
        Dim loadFileDialog1 As New OpenFileDialog

        loadFileDialog1.Filter = "xml files (*.xml)|*.xml"
        loadFileDialog1.FilterIndex = 2
        loadFileDialog1.RestoreDirectory = True

        If loadFileDialog1.ShowDialog = Windows.Forms.DialogResult.OK Then
            Try
                ahk.Clear()
                ahk.ReadXml(loadFileDialog1.FileName)
            Catch ex As Exception
                MsgBox("Load failed.")
            End Try
        End If

        If ahk.Rows.Count Then
            savexml.Enabled = True
        Else
            savexml.Enabled = False
        End If

        Me.DataGridView1.FirstDisplayedScrollingRowIndex = Me.DataGridView1.RowCount - 1
    End Sub

    Private Sub xcoord_TextChanged(sender As Object, e As EventArgs) Handles xcoord.TextChanged
        My.Settings.xcoord = xcoord.Text
    End Sub

    Private Sub ycoord_TextChanged(sender As Object, e As EventArgs) Handles ycoord.TextChanged
        My.Settings.ycoord = ycoord.Text
    End Sub

    Private Sub Button1_Click(sender As Object, e As EventArgs) Handles Button1.Click
        If xcoord.Text = "" Or ycoord.Text = "" Or db.Tables("ahk").Rows.Count = 0 Then
            MsgBox("X / Y coordinates missing or Not enough spells have been added yet.")
            Exit Sub
        End If

        Dim saveFileDialog1 As New SaveFileDialog()

        saveFileDialog1.Filter = "ahk files (*.ahk)|*.ahk"
        saveFileDialog1.FilterIndex = 2
        saveFileDialog1.RestoreDirectory = True

        If saveFileDialog1.ShowDialog() = DialogResult.OK Then
            Dim file As System.IO.StreamWriter

            Try
                My.Computer.FileSystem.DeleteFile(saveFileDialog1.FileName)
            Catch ex As Exception

            End Try

            Try
                file = My.Computer.FileSystem.OpenTextFileWriter(saveFileDialog1.FileName, True)
                file.WriteLine("loop")
                file.WriteLine("{")
                file.WriteLine("	if ( GetKeyState(""CapsLock"" ,""T"") ) {")
                file.WriteLine("		WinWaitActive, World of Warcraft,")
                file.WriteLine("		PixelGetColor, CLRx, " + xcoord.Text + ", " + ycoord.Text)
                If ahk.Rows.Count = 1 Then
                    file.WriteLine("		if (CLRx = """ + db.Tables("ahk").Rows(0).Item(2).ToString + """) { ; " + db.Tables("ahk").Rows(0).Item(0).ToString)
                    file.WriteLine("		    Send, " + db.Tables("ahk").Rows(0).Item(1).ToString)
                Else
                    file.WriteLine("		if (CLRx = """ + db.Tables("ahk").Rows(0).Item(2).ToString + """) { ; " + db.Tables("ahk").Rows(0).Item(0).ToString)
                    file.WriteLine("		    Send, " + db.Tables("ahk").Rows(0).Item(1).ToString)
                    For I As Integer = 1 To db.Tables("ahk").Rows.Count - 1
                        file.WriteLine("		} else if (CLRx = """ + db.Tables("ahk").Rows(I).Item(2).ToString + """) { ; " + db.Tables("ahk").Rows(I).Item(0).ToString)
                        file.WriteLine("		    Send, " + db.Tables("ahk").Rows(I).Item(1).ToString)
                    Next
                End If
                file.WriteLine("		}")
                file.WriteLine("	}")
                file.WriteLine("	Random, sleeprand, 25, 35")
                file.WriteLine("	Sleep, %sleeprand%")
                file.WriteLine("}")
                file.Close()
                MsgBox("AHK has been created.")
            Catch ex As Exception
                MsgBox("Oops...")
            End Try

        Else
            MsgBox("AHK creation failed.")
        End If
    End Sub

    Function UppercaseFirstLetter(ByVal val As String) As String
        ' Test for nothing or empty.
        If String.IsNullOrEmpty(val) Then
            Return val
        End If

        ' Convert to character array.
        Dim array() As Char = val.ToCharArray

        ' Uppercase first character.
        array(0) = Char.ToUpper(array(0))

        ' Return new string.
        Return New String(array)
    End Function

    Private Sub fkey_CheckedChanged(sender As Object, e As EventArgs) Handles fkey.CheckedChanged
        If fkey.Checked And numpad.Checked Then
            numpad.Checked = False
        End If
    End Sub

    Private Sub numpad_CheckedChanged(sender As Object, e As EventArgs) Handles numpad.CheckedChanged
        If numpad.Checked And fkey.Checked Then
            fkey.Checked = False
        End If
    End Sub

    Private Sub playerclass_SelectedIndexChanged(sender As Object, e As EventArgs) Handles playerclass.SelectedIndexChanged
        If playerclass.SelectedItem.ToString <> "" Then
            skillname.Items.Clear()
            Dim reader As New System.IO.StreamReader(wowdir.ToString + "interface\addons\Xeltors_Ovale_Scripts\class\" + playerclass.SelectedItem.ToString + "\Xeltor.lua")
            Dim stringReader As String
            Dim stringSplit As String()
            Do
                stringReader = reader.ReadLine()
                If stringReader.Contains("Define") And Not stringReader.Contains("talent") And Not stringReader.Contains("glyph") Then
                    stringReader = stringReader.Replace("Define(", "")
                    stringReader = stringReader.Replace(")", "")
                    stringSplit = stringReader.Split(" ")
                    stringReader = stringSplit(0).Replace("_", " ")
                    skillname.Items.Add(UppercaseFirstLetter(stringReader))
                ElseIf stringReader.Contains("AddIcon") Then
                    Exit Do
                End If
            Loop Until stringReader Is Nothing

            skillname.Enabled = True
        Else
            skillname.Enabled = False
        End If
    End Sub
End Class

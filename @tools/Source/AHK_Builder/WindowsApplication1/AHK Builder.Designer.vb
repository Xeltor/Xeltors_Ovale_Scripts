<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class main
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.button = New System.Windows.Forms.TextBox()
        Me.pixelcolor = New System.Windows.Forms.TextBox()
        Me.Label1 = New System.Windows.Forms.Label()
        Me.Label2 = New System.Windows.Forms.Label()
        Me.control = New System.Windows.Forms.CheckBox()
        Me.shift = New System.Windows.Forms.CheckBox()
        Me.alt = New System.Windows.Forms.CheckBox()
        Me.add = New System.Windows.Forms.Button()
        Me.db = New System.Data.DataSet()
        Me.ahk = New System.Data.DataTable()
        Me.spellname = New System.Data.DataColumn()
        Me.key = New System.Data.DataColumn()
        Me.pixel = New System.Data.DataColumn()
        Me.DataGridView1 = New System.Windows.Forms.DataGridView()
        Me.xcoord = New System.Windows.Forms.TextBox()
        Me.Label3 = New System.Windows.Forms.Label()
        Me.Label4 = New System.Windows.Forms.Label()
        Me.ycoord = New System.Windows.Forms.TextBox()
        Me.Label5 = New System.Windows.Forms.Label()
        Me.loadxml = New System.Windows.Forms.Button()
        Me.Button1 = New System.Windows.Forms.Button()
        Me.skillabel = New System.Windows.Forms.Label()
        Me.fkey = New System.Windows.Forms.CheckBox()
        Me.numpad = New System.Windows.Forms.CheckBox()
        Me.playerclass = New System.Windows.Forms.ComboBox()
        Me.skillname = New System.Windows.Forms.ComboBox()
        Me.Label6 = New System.Windows.Forms.Label()
        Me.findwow = New System.Windows.Forms.FolderBrowserDialog()
        Me.sqeaklock = New System.Windows.Forms.CheckBox()
        Me.DataGridViewTextBoxColumn1 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.DataGridViewTextBoxColumn2 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        Me.DataGridViewTextBoxColumn3 = New System.Windows.Forms.DataGridViewTextBoxColumn()
        CType(Me.db, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.ahk, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.DataGridView1, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuspendLayout()
        '
        'button
        '
        Me.button.Enabled = False
        Me.button.Location = New System.Drawing.Point(179, 101)
        Me.button.MaxLength = 2
        Me.button.Name = "button"
        Me.button.Size = New System.Drawing.Size(107, 20)
        Me.button.TabIndex = 2
        '
        'pixelcolor
        '
        Me.pixelcolor.Enabled = False
        Me.pixelcolor.Location = New System.Drawing.Point(471, 101)
        Me.pixelcolor.Name = "pixelcolor"
        Me.pixelcolor.Size = New System.Drawing.Size(133, 20)
        Me.pixelcolor.TabIndex = 6
        '
        'Label1
        '
        Me.Label1.AutoSize = True
        Me.Label1.Location = New System.Drawing.Point(176, 82)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(45, 13)
        Me.Label1.TabIndex = 2
        Me.Label1.Text = "Keybind"
        '
        'Label2
        '
        Me.Label2.AutoSize = True
        Me.Label2.Location = New System.Drawing.Point(468, 82)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(154, 13)
        Me.Label2.TabIndex = 2
        Me.Label2.Text = "Pixel color (Double click in box)"
        '
        'control
        '
        Me.control.AutoSize = True
        Me.control.Location = New System.Drawing.Point(292, 103)
        Me.control.Name = "control"
        Me.control.Size = New System.Drawing.Size(59, 17)
        Me.control.TabIndex = 3
        Me.control.Text = "Control"
        Me.control.UseVisualStyleBackColor = True
        '
        'shift
        '
        Me.shift.AutoSize = True
        Me.shift.Location = New System.Drawing.Point(357, 103)
        Me.shift.Name = "shift"
        Me.shift.Size = New System.Drawing.Size(47, 17)
        Me.shift.TabIndex = 4
        Me.shift.Text = "Shift"
        Me.shift.UseVisualStyleBackColor = True
        '
        'alt
        '
        Me.alt.AutoSize = True
        Me.alt.Location = New System.Drawing.Point(410, 103)
        Me.alt.Name = "alt"
        Me.alt.Size = New System.Drawing.Size(38, 17)
        Me.alt.TabIndex = 5
        Me.alt.Text = "Alt"
        Me.alt.UseVisualStyleBackColor = True
        '
        'add
        '
        Me.add.Enabled = False
        Me.add.Location = New System.Drawing.Point(612, 101)
        Me.add.Name = "add"
        Me.add.Size = New System.Drawing.Size(91, 19)
        Me.add.TabIndex = 7
        Me.add.Text = "Add"
        Me.add.UseVisualStyleBackColor = True
        '
        'db
        '
        Me.db.DataSetName = "NewDataSet"
        Me.db.Locale = New System.Globalization.CultureInfo("en")
        Me.db.Tables.AddRange(New System.Data.DataTable() {Me.ahk})
        '
        'ahk
        '
        Me.ahk.Columns.AddRange(New System.Data.DataColumn() {Me.spellname, Me.key, Me.pixel})
        Me.ahk.Constraints.AddRange(New System.Data.Constraint() {New System.Data.UniqueConstraint("Constraint1", New String() {"pixel"}, True)})
        Me.ahk.PrimaryKey = New System.Data.DataColumn() {Me.pixel}
        Me.ahk.TableName = "ahk"
        '
        'spellname
        '
        Me.spellname.AllowDBNull = False
        Me.spellname.ColumnName = "spellname"
        '
        'key
        '
        Me.key.Caption = "key"
        Me.key.ColumnName = "key"
        '
        'pixel
        '
        Me.pixel.AllowDBNull = False
        Me.pixel.Caption = "pixel"
        Me.pixel.ColumnName = "pixel"
        '
        'DataGridView1
        '
        Me.DataGridView1.AllowUserToResizeColumns = False
        Me.DataGridView1.AllowUserToResizeRows = False
        Me.DataGridView1.AutoGenerateColumns = False
        Me.DataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize
        Me.DataGridView1.Columns.AddRange(New System.Windows.Forms.DataGridViewColumn() {Me.DataGridViewTextBoxColumn1, Me.DataGridViewTextBoxColumn2, Me.DataGridViewTextBoxColumn3})
        Me.DataGridView1.DataMember = "ahk"
        Me.DataGridView1.DataSource = Me.db
        Me.DataGridView1.Location = New System.Drawing.Point(13, 128)
        Me.DataGridView1.Name = "DataGridView1"
        Me.DataGridView1.Size = New System.Drawing.Size(690, 438)
        Me.DataGridView1.TabIndex = 100
        '
        'xcoord
        '
        Me.xcoord.Location = New System.Drawing.Point(27, 10)
        Me.xcoord.Name = "xcoord"
        Me.xcoord.Size = New System.Drawing.Size(54, 20)
        Me.xcoord.TabIndex = 8
        '
        'Label3
        '
        Me.Label3.AutoSize = True
        Me.Label3.Location = New System.Drawing.Point(13, 13)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(12, 13)
        Me.Label3.TabIndex = 8
        Me.Label3.Text = "x"
        '
        'Label4
        '
        Me.Label4.AutoSize = True
        Me.Label4.Location = New System.Drawing.Point(79, 17)
        Me.Label4.Name = "Label4"
        Me.Label4.Size = New System.Drawing.Size(10, 13)
        Me.Label4.TabIndex = 9
        Me.Label4.Text = ","
        '
        'ycoord
        '
        Me.ycoord.Location = New System.Drawing.Point(110, 10)
        Me.ycoord.Name = "ycoord"
        Me.ycoord.Size = New System.Drawing.Size(56, 20)
        Me.ycoord.TabIndex = 9
        '
        'Label5
        '
        Me.Label5.AutoSize = True
        Me.Label5.Location = New System.Drawing.Point(96, 13)
        Me.Label5.Name = "Label5"
        Me.Label5.Size = New System.Drawing.Size(12, 13)
        Me.Label5.TabIndex = 8
        Me.Label5.Text = "y"
        '
        'loadxml
        '
        Me.loadxml.Location = New System.Drawing.Point(628, 12)
        Me.loadxml.Name = "loadxml"
        Me.loadxml.Size = New System.Drawing.Size(75, 23)
        Me.loadxml.TabIndex = 11
        Me.loadxml.Text = "Load"
        Me.loadxml.UseVisualStyleBackColor = True
        '
        'Button1
        '
        Me.Button1.Location = New System.Drawing.Point(275, 12)
        Me.Button1.Name = "Button1"
        Me.Button1.Size = New System.Drawing.Size(136, 34)
        Me.Button1.TabIndex = 12
        Me.Button1.Text = "Create AHK"
        Me.Button1.UseVisualStyleBackColor = True
        '
        'skillabel
        '
        Me.skillabel.AutoSize = True
        Me.skillabel.Location = New System.Drawing.Point(13, 82)
        Me.skillabel.Name = "skillabel"
        Me.skillabel.Size = New System.Drawing.Size(59, 13)
        Me.skillabel.TabIndex = 13
        Me.skillabel.Text = "Spell name"
        '
        'fkey
        '
        Me.fkey.AutoSize = True
        Me.fkey.Location = New System.Drawing.Point(292, 82)
        Me.fkey.Name = "fkey"
        Me.fkey.Size = New System.Drawing.Size(52, 17)
        Me.fkey.TabIndex = 101
        Me.fkey.Text = "F key"
        Me.fkey.UseVisualStyleBackColor = True
        '
        'numpad
        '
        Me.numpad.AutoSize = True
        Me.numpad.Location = New System.Drawing.Point(357, 82)
        Me.numpad.Name = "numpad"
        Me.numpad.Size = New System.Drawing.Size(86, 17)
        Me.numpad.TabIndex = 102
        Me.numpad.Text = "Numpad key"
        Me.numpad.UseVisualStyleBackColor = True
        '
        'playerclass
        '
        Me.playerclass.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.playerclass.FormattingEnabled = True
        Me.playerclass.Location = New System.Drawing.Point(13, 58)
        Me.playerclass.Name = "playerclass"
        Me.playerclass.Size = New System.Drawing.Size(134, 21)
        Me.playerclass.TabIndex = 103
        '
        'skillname
        '
        Me.skillname.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList
        Me.skillname.Enabled = False
        Me.skillname.FormattingEnabled = True
        Me.skillname.Location = New System.Drawing.Point(13, 101)
        Me.skillname.Name = "skillname"
        Me.skillname.Size = New System.Drawing.Size(134, 21)
        Me.skillname.TabIndex = 104
        '
        'Label6
        '
        Me.Label6.AutoSize = True
        Me.Label6.Location = New System.Drawing.Point(13, 42)
        Me.Label6.Name = "Label6"
        Me.Label6.Size = New System.Drawing.Size(32, 13)
        Me.Label6.TabIndex = 105
        Me.Label6.Text = "Class"
        '
        'findwow
        '
        Me.findwow.Description = "Please select your World of Warcraft folder."
        '
        'sqeaklock
        '
        Me.sqeaklock.AutoSize = True
        Me.sqeaklock.Location = New System.Drawing.Point(417, 13)
        Me.sqeaklock.Name = "sqeaklock"
        Me.sqeaklock.Size = New System.Drawing.Size(101, 17)
        Me.sqeaklock.TabIndex = 106
        Me.sqeaklock.Text = "Use Scroll Lock"
        Me.sqeaklock.UseVisualStyleBackColor = True
        '
        'DataGridViewTextBoxColumn1
        '
        Me.DataGridViewTextBoxColumn1.DataPropertyName = "spellname"
        Me.DataGridViewTextBoxColumn1.HeaderText = "Spell name"
        Me.DataGridViewTextBoxColumn1.Name = "DataGridViewTextBoxColumn1"
        '
        'DataGridViewTextBoxColumn2
        '
        Me.DataGridViewTextBoxColumn2.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill
        Me.DataGridViewTextBoxColumn2.DataPropertyName = "key"
        Me.DataGridViewTextBoxColumn2.HeaderText = "Keybind"
        Me.DataGridViewTextBoxColumn2.Name = "DataGridViewTextBoxColumn2"
        '
        'DataGridViewTextBoxColumn3
        '
        Me.DataGridViewTextBoxColumn3.DataPropertyName = "pixel"
        Me.DataGridViewTextBoxColumn3.HeaderText = "Pixel color"
        Me.DataGridViewTextBoxColumn3.Name = "DataGridViewTextBoxColumn3"
        '
        'main
        '
        Me.AcceptButton = Me.add
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(715, 578)
        Me.Controls.Add(Me.sqeaklock)
        Me.Controls.Add(Me.Label6)
        Me.Controls.Add(Me.skillname)
        Me.Controls.Add(Me.playerclass)
        Me.Controls.Add(Me.numpad)
        Me.Controls.Add(Me.fkey)
        Me.Controls.Add(Me.skillabel)
        Me.Controls.Add(Me.Button1)
        Me.Controls.Add(Me.loadxml)
        Me.Controls.Add(Me.Label5)
        Me.Controls.Add(Me.Label3)
        Me.Controls.Add(Me.ycoord)
        Me.Controls.Add(Me.xcoord)
        Me.Controls.Add(Me.DataGridView1)
        Me.Controls.Add(Me.add)
        Me.Controls.Add(Me.alt)
        Me.Controls.Add(Me.shift)
        Me.Controls.Add(Me.control)
        Me.Controls.Add(Me.Label2)
        Me.Controls.Add(Me.Label1)
        Me.Controls.Add(Me.pixelcolor)
        Me.Controls.Add(Me.button)
        Me.Controls.Add(Me.Label4)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle
        Me.MaximizeBox = False
        Me.Name = "main"
        Me.Text = "AHK Builder"
        CType(Me.db, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.ahk, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.DataGridView1, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents button As System.Windows.Forms.TextBox
    Friend WithEvents pixelcolor As System.Windows.Forms.TextBox
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents control As System.Windows.Forms.CheckBox
    Friend WithEvents shift As System.Windows.Forms.CheckBox
    Friend WithEvents alt As System.Windows.Forms.CheckBox
    Friend WithEvents add As System.Windows.Forms.Button
    Friend WithEvents db As System.Data.DataSet
    Friend WithEvents DataGridView1 As System.Windows.Forms.DataGridView
    Friend WithEvents xcoord As System.Windows.Forms.TextBox
    Friend WithEvents Label3 As System.Windows.Forms.Label
    Friend WithEvents Label4 As System.Windows.Forms.Label
    Friend WithEvents ycoord As System.Windows.Forms.TextBox
    Friend WithEvents Label5 As System.Windows.Forms.Label
    Friend WithEvents loadxml As System.Windows.Forms.Button
    Friend WithEvents Button1 As System.Windows.Forms.Button
    Friend WithEvents skillabel As System.Windows.Forms.Label
    Friend WithEvents ahk As System.Data.DataTable
    Friend WithEvents spellname As System.Data.DataColumn
    Friend WithEvents key As System.Data.DataColumn
    Friend WithEvents pixel As System.Data.DataColumn
    Friend WithEvents fkey As System.Windows.Forms.CheckBox
    Friend WithEvents numpad As System.Windows.Forms.CheckBox
    Friend WithEvents playerclass As System.Windows.Forms.ComboBox
    Friend WithEvents skillname As System.Windows.Forms.ComboBox
    Friend WithEvents Label6 As System.Windows.Forms.Label
    Friend WithEvents findwow As System.Windows.Forms.FolderBrowserDialog
    Friend WithEvents sqeaklock As System.Windows.Forms.CheckBox
    Friend WithEvents DataGridViewTextBoxColumn1 As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents DataGridViewTextBoxColumn2 As System.Windows.Forms.DataGridViewTextBoxColumn
    Friend WithEvents DataGridViewTextBoxColumn3 As System.Windows.Forms.DataGridViewTextBoxColumn

End Class

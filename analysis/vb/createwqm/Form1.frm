VERSION 5.00
Begin VB.Form frmWQMSub 
   Caption         =   "Create a WQM Subset "
   ClientHeight    =   3840
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   5955
   LinkTopic       =   "Form1"
   ScaleHeight     =   3840
   ScaleWidth      =   5955
   StartUpPosition =   3  'Windows Default
   Begin VB.DirListBox Dir1 
      Height          =   2790
      Left            =   120
      TabIndex        =   3
      Top             =   720
      Width           =   3375
   End
   Begin VB.FileListBox File1 
      Height          =   2820
      Left            =   3720
      TabIndex        =   2
      Top             =   720
      Width           =   2055
   End
   Begin VB.CommandButton cmdExit 
      Caption         =   "Exit"
      Height          =   495
      Left            =   4560
      TabIndex        =   1
      Top             =   120
      Width           =   1215
   End
   Begin VB.CommandButton cmdRun 
      Caption         =   "Create WQM Subst"
      Height          =   495
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   1695
   End
End
Attribute VB_Name = "frmWQMSub"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim myWQM As String
'Dim my1980 As String
'Dim my1990 As String
'Dim my2000 As String
Dim newWQM As String

Dim myDataPath As String

Private Sub cmdExit_Click()
    End
End Sub

Private Sub cmdRun_Click()
'creates a subset access file
'from a spatial subset textfile, already defined
'1) here the user is asked to navigate to a text file containing only
'   FRDS-ID numbers
'2) then the application selects, out of the wqm decade databases
'   all of the relating records will all constituent basis

'get the text file
' Dir1.Path + "\" + File1.FileName
    
'    ClearTemp  I will need some file handling for the new db here

'open the file to read
Open Dir1.Path + "\" + File1.FileName For Input As #1  'Open the file 'Random Access Read
Dim myStr As String
Do Until EOF(1)
    Line Input #1, myStr
    GetStatNo myStr
Loop
Close 1
MsgBox "DONE!"



'read the text file into an array
'retrieve each recordset for each decade
'populate into a table
End Sub

'Private Sub Command1_Click()
'Dim chemDB As Database
'Dim myCount As Integer
'Dim myBol As Boolean

'myBol = False
'For i = 1980 To 2000 Step 10
'    Set chemDB = OpenDatabase(myDataPath + "\chem" + Trim(Str(i)) + "s.mdb")
'    myCount = chemDB.TableDefs.Count
'    For j = i To i + 9
'        'MsgBox "the supposed name is " + "chem" + Trim(Str(j)) + " and the real name is " + chemDB.TableDefs(1).Name
'        For k = 0 To myCount - 1
'            If Trim(chemDB.TableDefs(k).Name) = Trim("Chem" + Trim(Str(j))) Then
'                MsgBox chemDB.TableDefs(k).Name
'                myBol = True
'            End If
'        Next k
'        If myBol = True Then
'
'        'MsgBox "Table chem" + Str(Trim(j)) + " is " + myBol
'    Next j
'    chemDB.Close
'    Set chemDB = Nothing
'Next i

'End Sub


Private Sub Dir1_Change()
    File1.Path = Dir1.Path
    File1.Pattern = "*.txt"
End Sub


Private Sub Form_Load()

    myDataPath = "D:\projects\academic\thesis\data\databases\wqm"
    Dir1.Path = DataPath
    File1.Path = Dir1.Path
    File1.Pattern = "*.txt"
    
    myWQM = myDataPath + "\wqm.mdb"
    
    'my1980 = DataPath + "\chem1980s.mdb"
    'my1990 = DataPath + "\chem1990s.mdb"
    'my2000 = DataPath + "\chem2000s.mdb"
    
    newWQM = myDataPath + "\template.mdb"
End Sub

Public Sub GetStatNo(FrdsID As String)
    Dim db As Database
    Dim rs As Recordset
    Dim mySQL As String
    Set db = OpenDatabase(myWQM)
    mySQL = "Select [Prim_Sta_C] from SiteLoc where [Frds_No] = '" & FrdsID & "' ;"
    Set rs = db.OpenRecordset(mySQL)
    If rs.RecordCount > 0 Then
        GetWQM rs.Fields(0), FrdsID
    End If
    rs.Close
    db.Close
    Set rs = Nothing
    Set db = Nothing
End Sub

Public Sub GetWQM(StationNo As String, FrdsID As String)
    Dim chemDB As Database
    Dim chemRS As Recordset
    Dim mySQL As String
    Dim myCount As Integer

For i = 1980 To 2000 Step 10
    'Set chemDB = OpenDatabase(my1980)
    Set chemDB = OpenDatabase(myDataPath + "\chem" + Trim(Str(i)) + "s.mdb")
    myCount = chemDB.TableDefs.Count
    For j = i To i + 9
      For k = 0 To myCount - 1
        If Trim(chemDB.TableDefs(k).Name) = Trim("Chem" + Trim(Str(j))) Then
            mySQL = "Select * from chem" + Trim(Str(j)) + " where [Prim_sta_C] = '" & StationNo & "' ;"
            Set chemRS = chemDB.OpenRecordset(mySQL)
            If chemRS.RecordCount > 0 Then  'then populate all records in the template (new)
                'MsgBox "inside popspatial." + StationNo + " has " + Str(rs.RecordCount) + " records"
                PopNewWQM chemRS, FrdsID
            End If
            chemRS.Close
            Set chemRS = Nothing
        End If
      Next k
    Next j
    chemDB.Close
    Set chemDB = Nothing
Next i

End Sub

Public Sub PopNewWQM(myRS As Recordset, FrdsID As String)
    Dim newDB As Database
    Dim mySQL As String

    Set newDB = OpenDatabase(newWQM)
    While Not myRS.EOF
        mySQL = "INSERT into Template ([Con_Pkey],[Samp_Date],[Store_Num],Finding) Values ( '" & _
            FrdsID & "' , #" & myRS.Fields(1) & "# , '" & _
            myRS.Fields(9) & "' , " & _
            myRS.Fields(11) & ");"
        'MsgBox mySQL
        newDB.Execute (mySQL)
        myRS.MoveNext
    Wend
    newDB.Close
    Set newDB = Nothing
End Sub

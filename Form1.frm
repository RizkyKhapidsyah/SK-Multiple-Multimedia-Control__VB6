VERSION 5.00
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "Comdlg32.ocx"
Object = "{C1A8AF28-1257-101B-8FB0-0020AF039CA3}#1.1#0"; "MCI32.OCX"
Begin VB.Form Form1 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Multiple Multimedia Control Sample"
   ClientHeight    =   4755
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   6405
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4755
   ScaleWidth      =   6405
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.Frame Frame2 
      Caption         =   "Record"
      Height          =   2175
      Left            =   120
      TabIndex        =   1
      Top             =   2400
      Width           =   6135
      Begin VB.CheckBox Check1 
         Caption         =   "Use control panel recording format"
         Height          =   255
         Left            =   2880
         TabIndex        =   12
         Top             =   960
         Width           =   2895
      End
      Begin VB.ComboBox Combo2 
         Height          =   315
         Left            =   1800
         TabIndex        =   10
         Text            =   "<select soundcard>"
         Top             =   360
         Width           =   4215
      End
      Begin MCI.MMControl MMControl2 
         Height          =   375
         Left            =   120
         TabIndex        =   7
         Top             =   1560
         Width           =   3150
         _ExtentX        =   5556
         _ExtentY        =   661
         _Version        =   393216
         EjectVisible    =   0   'False
         DeviceType      =   "waveaudio"
         FileName        =   ""
      End
      Begin VB.CommandButton recSave 
         Caption         =   "save"
         Height          =   375
         Left            =   1200
         TabIndex        =   6
         Top             =   960
         Width           =   975
      End
      Begin VB.CommandButton recOpen 
         Caption         =   "open"
         Height          =   375
         Left            =   120
         TabIndex        =   5
         Top             =   960
         Width           =   975
      End
      Begin MSComDlg.CommonDialog CommonDialog2 
         Left            =   5640
         Top             =   1440
         _ExtentX        =   847
         _ExtentY        =   847
         _Version        =   393216
         DefaultExt      =   "wav"
         FileName        =   "*.wav"
         Filter          =   "*.wav"
      End
      Begin VB.Label Label3 
         Caption         =   "Wave Input Devices"
         Height          =   255
         Left            =   120
         TabIndex        =   11
         Top             =   360
         Width           =   1575
      End
   End
   Begin VB.Frame Frame1 
      Caption         =   "Play"
      Height          =   2175
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   6135
      Begin VB.ComboBox Combo1 
         Height          =   315
         Left            =   1800
         TabIndex        =   8
         Text            =   "<select soundcard>"
         Top             =   360
         Width           =   4215
      End
      Begin MCI.MMControl MMControl1 
         Height          =   375
         Left            =   120
         TabIndex        =   4
         Top             =   1560
         Width           =   2760
         _ExtentX        =   4868
         _ExtentY        =   661
         _Version        =   393216
         RecordVisible   =   0   'False
         EjectVisible    =   0   'False
         DeviceType      =   "waveaudio"
         FileName        =   ""
      End
      Begin MSComDlg.CommonDialog CommonDialog1 
         Left            =   5640
         Top             =   1440
         _ExtentX        =   847
         _ExtentY        =   847
         _Version        =   393216
         DefaultExt      =   "wav"
         FileName        =   "*.wav"
         Filter          =   "*.wav"
      End
      Begin VB.CommandButton playOpen 
         Caption         =   "open file"
         Height          =   375
         Left            =   120
         TabIndex        =   2
         Top             =   960
         Width           =   975
      End
      Begin VB.Label Label2 
         Caption         =   "Wave Output Devices"
         Height          =   255
         Left            =   120
         TabIndex        =   9
         Top             =   360
         Width           =   1695
      End
      Begin VB.Label Label1 
         BorderStyle     =   1  'Fixed Single
         Height          =   375
         Left            =   1200
         TabIndex        =   3
         Top             =   960
         Width           =   4815
      End
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub Form_Load()
   Dim numDevs As Long
   Dim idx As Long
   Dim outcaps As WAVEOUTCAPS
   Dim incaps As WAVEINCAPS
   
   ' Get the available wave output devices
   numDevs = waveOutGetNumDevs
   
   For idx = 0 To numDevs - 1
      waveOutGetDevCaps idx, outcaps, Len(outcaps)
      Combo1.AddItem outcaps.szPname
   Next
   
   ' Get the available wave input devices
   numDevs = waveInGetNumDevs
   
   For idx = 0 To numDevs - 1
      waveInGetDevCaps idx, incaps, Len(incaps)
      Combo2.AddItem incaps.szPname
   Next
End Sub

Private Sub MMControl1_PlayClick(Cancel As Integer)
   Dim parms As MCI_WAVE_SET_PARMS
   Dim rc As Long
   Dim msg As String * 300
   
   ' Set the output device for mmcontrol1
   parms.wOutput = Combo1.ListIndex
   rc = mciSendCommand(MMControl1.DeviceID, MCI_SET, MCI_WAVE_OUTPUT, parms)
   
   If (rc <> NO_ERROR) Then
      mciGetErrorString rc, msg, Len(msg)
      MsgBox msg
   End If

End Sub

Private Sub MMControl2_RecordClick(Cancel As Integer)
   Dim parms As MCI_WAVE_SET_PARMS
   Dim rc As Long
   Dim msg As String * 300
   
   ' Set the record/playback device for mmcontrol2
   parms.wInput = Combo2.ListIndex
   parms.wOutput = Combo2.ListIndex
   rc = mciSendCommand(MMControl2.DeviceID, _
                        MCI_SET, _
                        MCI_WAVE_INPUT Or MCI_WAVE_OUTPUT, _
                        parms)
                        
   If (rc <> NO_ERROR) Then
      mciGetErrorString rc, msg, Len(msg)
      MsgBox msg
   End If
   
   ' Use control panel record format if option is checked
   If (Check1.Value = 1) Then
      Dim wf As WAVEFORMAT
      If (GetDefaultWaveFormat(wf) = False) Then
         MsgBox "Couldn't get the default format"
      Else
         parms.nAvgBytesPerSec = wf.nAvgBytesPerSec
         parms.nBlockAlign = wf.nBlockAlign
         parms.nChannels = wf.nChannels
         parms.nSamplesPerSec = wf.nSamplesPerSec
         parms.wBitsPerSample = wf.wBitsPerSample
         parms.wFormatTag = wf.wFormatTag
         rc = mciSendCommand(MMControl2.DeviceID, _
                              MCI_SET, _
                              MCI_WAVE_SET_SAMPLESPERSEC Or _
                              MCI_WAVE_SET_AVGBYTESPERSEC Or _
                              MCI_WAVE_SET_BITSPERSAMPLE Or _
                              MCI_WAVE_SET_BLOCKALIGN Or _
                              MCI_WAVE_SET_CHANNELS Or _
                              MCI_WAVE_SET_FORMATTAG, _
                              parms)
                              
         If (rc <> NO_ERROR) Then
            mciGetErrorString rc, msg, Len(msg)
            MsgBox msg
         End If
      End If
   End If
End Sub

Private Sub playOpen_Click()
   MMControl1.Command = "close"    ' close previously open file
   CommonDialog1.ShowOpen
   Label1.Caption = CommonDialog1.FileName
   MMControl1.FileName = CommonDialog1.FileName
   MMControl1.Command = "open"
End Sub

Private Sub recOpen_Click()
   MMControl2.Command = "close"    ' close previously open file
   MMControl2.FileName = "new"
   MMControl2.Command = "open"
End Sub

Private Sub recSave_Click()
   CommonDialog2.ShowSave
   MMControl2.FileName = CommonDialog2.FileName
   MMControl2.Command = "save"
End Sub

Private Function GetDefaultWaveFormat(format As WAVEFORMAT) As Boolean
'////////////////////////////////////////////////////////////////////////////////////
' This user-defined function retrieves the default wave format from the registry.
'////////////////////////////////////////////////////////////////////////////////////
   Dim rc As Long
   Dim key1 As Long
   Dim key2 As Long
   Dim formatName As String * 50
   Dim length As Long
   
   ' Initialize return code
   GetDefaultWaveFormat = False
    
   rc = RegOpenKeyEx(HKEY_CURRENT_USER, _
                     "Software\Microsoft\Multimedia\Audio", _
                     0, _
                     KEY_READ, _
                     key1)
   If (rc <> 0) Then
      Exit Function
   End If
   
   length = Len(formatName)
   rc = RegQueryValueString(key1, "DefaultFormat", 0, 0, formatName, length)
   
   If (NO_ERROR = rc) Then
      rc = RegOpenKeyEx(HKEY_CURRENT_USER, _
                        "Software\Microsoft\Multimedia\Audio\WaveFormats", _
                        0, _
                        KEY_READ, _
                        key2)
                        
      If (NO_ERROR = rc) Then
         length = Len(format)
         rc = RegQueryValueEx(key2, _
                              formatName, _
                              0, _
                              0, _
                              format, _
                              length)
         RegCloseKey key2
         
         If (NO_ERROR = rc) Then
            GetDefaultWaveFormat = True
         End If
      End If
   End If
   RegCloseKey key1
End Function

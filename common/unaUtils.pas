
(*
	----------------------------------------------
	  unaUtils.pas
	----------------------------------------------
	  Copyright (c) 2001-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, 25 Aug 2001

	  modified by:
		Lake, Aug-Dec 2001
		Lake, Jan-Dec 2002
		Lake, Jan-Dec 2003
		Lake, Jan-Dec 2004
		Lake, Jan-Dec 2005
		Lake, Jan-Dec 2006
		Lake, Jan-Dec 2007
		Lake, Jan-Oct 2008
		Lake, Jun-Dec 2009
		Lake, Jan-Nov 2010

	----------------------------------------------
*)

{$I unaDef.inc }

{xx $DEFINE HOOK_EXCEPTIONS_ALWAYS }		// when defined will hook exceptions regardless to symbol __SYSUTILS_H_ definition
						// when not defined exceptions will be hooked only when symbol __SYSUTILS_H_ is not defined

{x $DEFINE UNAUTILS_MEM_USE_HEAP_CALLS }	// define to use HeapAlloc()/HeapReAlloc() instead of Borland memory manager

{x $DEFINE CONSOLE_IO }				// defien to declare and initialize I/O handles: g_CONIN and g_CONOUT

{$IFDEF DEBUG }
  //
  {$DEFINE LOG_UNAUTILS_INFOS }		// log informational messages
  {$DEFINE LOG_UNAUTILS_ERRORS }	// log fatal error messages
  //
  {$IFDEF __AFTER_D9__ }
    //
    {x $DEFINE UNAUTILS_DEBUG_MEM }	// enable memory allocations calcualtions (g_allocMemSize will be valid)
					// NOTE: If UNAUTILS_DEBUG_MEM is defined, ams() will return size of
					//       memory allocated by malloc()/mrealloc() routines only.

    {x $DEFINE LOG_UNAUTILS_MALLOCS } 	// enable memory allocations logging
    //
  {$ENDIF __AFTER_D9__ }
  //
  {xx $DEFINE CHECK_MEMORY_LEAKS }	// enable memory leaks checking routines
  //
{$ENDIF DEBUG }

{*
  Contains useful routines used by other units and classes.

  @Author Lake
  @Version 2.5.2008.10 + CodeGear RAD 2009 compatible;
  @Version 2.5.2008.07 + aware of BDS 2006's and later improved memory manager;
  @Version 2.5.2009.12 + removed variant stuff
  @Version 2.5.2010.01 + some cleanup
}

unit
  unaUtils;

interface

uses
  Windows, unaTypes
{$IFDEF __SYSUTILS_H_ }
  , SysUtils
{$ENDIF __SYSUTILS_H_ }

{$IFDEF FPC }
{$ELSE }
  , TlHelp32
{$ENDIF FPC }
  ;


{
  Note from Delphi Help.

procedure Test(A: Integer; var B: Char; C: Double; const D: string; E: Pointer);

  - a call to Test passes A in EAX as a 32-bit integer,
			  B in EDX as a pointer to a Char,
		      and D in ECX as a pointer to a long-string memory block;
    C and E are pushed onto the stack as two double-words and a 32-bit pointer,
    in that order.

Under the register convention, Self behaves as if it were declared before
all other parameters. It is therefore always passed in the EAX register.

For a string, dynamic array, method pointer, variant, or Int64 result,
the effects are the same as if the function result were declared as an additional
var parameter following the declared parameters. In other words, the caller passes
an additional 32-bit pointer that points to a variable in which to return the
function result.

Register saving conventions
Procedures and functions must preserve the EBX, ESI, EDI, and EBP registers,
but can modify the EAX, EDX, and ECX registers. When implementing a
constructor or destructor in assembler, be sure to preserve the DL register.

Procedures and functions are invoked with the assumption that the CPU’s direction
flag is cleared (corresponding to a CLD instruction) and must return with the
direction flag cleared.

}

// some MATH

{*
	Returms minimal value of two signed integers.

	@return A if A < B, or B otherwise.
}
function min(A, B: int): int; 		overload;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
{*
	Returms minimal value of two unsigned integers.

	@return A if A < B, or B otherwise.
}
function min(A, B: unsigned): unsigned; overload;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }

{$IFNDEF CPU64 }

{*
	Returms minimal value of two signed 64 bits integers.

	@return A if A < B, or B otherwise.
}
function min(A, B: int64): int64; 	overload;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
{*
	Returns maximal value of two signed 64 bits integers.

	@return A if A < B, or B otherwise.
}
function max(A, B: int64): int64; 	overload;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }

{$ENDIF CPU64 }

{*
	Returns maximal value of two signed integers.

	@return A if A &gt; B, or B otherwise.
}
function max(A, B: int): int; 		overload;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
{*
	Returns maximal value of two unsigned integers.

	@return A if A &gt; B, or B otherwise.
}
function max(A, B: unsigned): unsigned; overload;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
{*
	Returns maximal value of two floating-point.

	@return A if A &gt; B, or B otherwise.
}
function max(A, B: double): double;	overload;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }

{$IFDEF __SYSUTILS_H_ }
{$ELSE }

{*
	Divides 1 by zero to rise an exception.
}
procedure abort();

{$ENDIF __SYSUTILS_H_ }


//	ENCODING

{*
	Encodes data with base64 method.

	@param data Data to be encoded.
	@param len Size of buffer pointed by data.

	@return Encoded value as string.
}
function base64encode(data: pointer; size: unsigned): aString; overload;
{*
	Encodes string with base64 method.

	@param data String of bytes to be encoded.

	@return Encoded value as string.
}
function base64encode(const data: aString): aString; overload;
{*
	Decodes string encoded with base64 method.

	@param data String of bytes to be decoded.

	@return Decoded value as string.
}
function base64decode(const data: aString): aString; overload;
{*
	Decodes data encoded with base64 method.

	@param data Data to be decoded.
	@param len Size of buffer pointed by data.

	@return Decoded value as string.
}
function base64decode(data: pointer; len: unsigned): aString; overload;
{*
	Decodes string encoded with base64 method.
	NOTE: buf will be allocated (not reallocated!).

	@param data String of bytes to be decoded.
	@param buf Output buffer. Use mrealloc() to deallocate memory pointed by buf.
	
	@return Number of bytes in output buffer.
}
function base64decode(const data: aString; out buf: pointer): unsigned; overload;

{*
	  Encodes data with "base65" method.

	  @return Encoded value as string.
}
function base65encode(data: pointer; len: unsigned): aString; overload;
{*
	  Encodes data with "base65" method.

	  @return Encoded value as string.
}
function base65encode(const data: aString): aString; overload;
{*
	  Decodes data encoded with "base65" method.

	  @return Dencoded value as string.
}
function base65decode(data: pointer; len: unsigned): aString; overload;
{*
	  Decodes data encoded with "base65" method.

	  @return Dencoded value as string.
}
function base65decode(const data: aString): aString; overload;

// --  --
{*
	  Encodes data with "X" method.

	  @return Dencoded value as string.
}
function baseXencode(const data, key: aString; ver: int): aString;
{*
	  Decodes data encoded with "X" method.

	  @return Dencoded value as string.
}
function baseXdecode(const data, key: aString; ver: int): aString;

{*
	Calculates CRC32 checksum.
	Based on Hagen Reddmann code.

	@param data String of bytes to calculate CRC32 of.
	@param crc Initial CRC value, do not change.
	@returm 	CRC32 value.
}
function crc32(const data: aString; crc: uint32 = $FFFFFFFF): uint32; overload;
{*
	Calculates CRC32 checksum.
	Based on Hagen Reddmann code.

	@param data Pointer to array of bytes to calculate CRC32 of.
	@param len Size of array pointed by data.
	@param crc Initial CRC value, do not change.
	@returm 	CRC32 value.
}
function crc32(data: pointer; len: unsigned; crc: uint32 = $FFFFFFFF): uint32; overload;
{*
	Calculates "CRC16" checksum. CRC16 is defined as "(crc shr 16) xor (crc and $FFFF)" where crc is standard CRC32 value.
	Based on Hagen Reddmann code.

	@param data Pointer to array of bytes to calculate CRC16 of.
	@param len Size of array pointed by data.
	@returm 	CRC16 value.
}
function crc16(data: pointer; len: unsigned): uint16;
{*
	Calculates "CRC8" checksum.
	Based on Hagen Reddmann code.

	@param data Pointer to array of bytes to calculate CRC8 of.
	@param len Size of array pointed by data.
	@returm 	CRC8 value.
}
function crc8(data: pointer; len: unsigned): uint8;
{*
	Calculates "CRC4" checksum.
	Based on Hagen Reddmann code.

	@param data Pointer to array of bytes to calculate CRC4 of.
	@param len Size of array pointed by data.
	@returm 	CRC4 value.
}
function crc4(data: pointer; len: unsigned): uint8;


// UTF8/UTF16/UNICODE functions

const
  //
  zeroWidthNonBreakingSpace     = $FEFF;
  zeroWidthNonBreakingSpaceW 	= wChar(zeroWidthNonBreakingSpace);
  zeroWidthNonBreakingSpaceUTF8 = #$EF#$BB#$BF;

  //
  unicodeHighSurrogateStart = $D800;
  unicodeHighSurrogateEnd   = $DBFF;
  unicodeLowSurrogateStart  = $DC00;
  unicodeLowSurrogateEnd    = $DFFF;

function cp2UTF8(cp: uint32): aString;
function highSurrogate(cp: uint32): uint16;
function lowSurrogate(cp: uint32): uint16;
function isHighSurrogate(w: uint16): bool;
function isLowSurrogate(w: uint16): bool;
function surrogate2cp(highSurrogate, lowSurrogate: uint16): uint32;
{*
	Converts UCS-2 to UTF-8 string.

	@param w UTF16 string.
	@return UTF8 string.
}
function UTF162UTF8(const w: wString): aString;
{*
	Converts UTF-8 to low-endian UCS-2 string.

	@param s UTF-8 string to be converted.
	@return UCS-2 string.
}
function UTF82UTF16(const s: aString): wString;
{*
	Converts multi-byte string into ANSI string using wCharToMultiByte().

	@param w Multi-byte string to be converted.
	@param cp code page to use for conversion, default is CP_ACP.

	@return ANSI string (single-byte string).
}
function wide2ansi(const w: wString; cp: unsigned = CP_ACP): aString;


//	FILES

//
// Borland had "misspelled" the declarations of the below functions a little,
// so we re-define them here.
//
{$EXTERNALSYM ReadFile }
function ReadFile(hFile: tHandle; buffer: pointer; nNumberOfBytesToRead: DWORD; lpNumberOfBytesRead: LPDWORD; lpOverlapped: POVERLAPPED): BOOL; stdcall;
{$EXTERNALSYM WriteFile }
function WriteFile(hFile: tHandle; buffer: pointer; nNumberOfBytesToWrite: DWORD; lpNumberOfBytesWritten: LPDWORD; lpOverlapped: POVERLAPPED): BOOL; stdcall;

{*
	Returns nice string representing file size.

	@param sz File size.

	@return String representation of sz.
}
function fileSize2str(sz: int64): string;

{*
	Checks if specified file exists.

	@param name File name.

	@return True if specified file exists.
}
function fileExists(const name: wString): bool;

{*
	Creates a file. If file already exists, truncates it to zero-length file (if truncate is true).

	@param name Name of file to be created (opened).
	@param truncate True if existing file must be truncated afer opening (default is True).
	@param leaveOpen Do not close file handle after creation (default is False).
	@param flags Creation flags (refer to MSDN for details).

	@return INVALID_HANDLE_VALUE if file creation has been failed for some reason;
	@return 0 if file was created successfully, and leaveOpen was False;
	@return file handle if file was created successfully, and leaveOpen was True.
}
function fileCreate(const name: wString; truncate: bool = true; leaveOpen: bool = false; flags: DWORD = 0): tHandle;
{*
	Opens a file.

	@param name Name of file to be opened.
	@param wantWrites Try to open a file with WRITE access if True, or READONLY if False (default is False).
	@param allowSharedWrites Allow others to write to opened file (default is True).
	@param flags Any additional flags. For example, specify FILE_FLAG_BACKUP_SEMANTICS flag when opening directories.

	@return INVALID_HANDLE_VALUE if file does not exist, or some other error occured, valid file handle otherwise.
}
function fileOpen(const name: wString; wantWrites: bool = false; allowSharedWrites: bool = true; flags: DWORD = FILE_ATTRIBUTE_NORMAL): tHandle;
{*
	Closes file handle.
}
function fileClose(f: tHandle): bool;
{*
	Truncates file at specified position.

	@return False if truncation has been failed for some reason.
}
function fileTruncate(handle: tHandle; pos: unsigned = 0; posMode: unsigned = FILE_BEGIN): bool;
{*
	Writes data into a file specified by name at specified position.
	Creates the file if it does not exists.

	@return 0 if operation has been completed successfully, or buf = nil, or size &lt; 1;
	@return -1 if no file name was given;
	@return -2 if there was some error in opening the file;
	@return -3 if operation has been failed for some reason;
	@return -4 if number of bytes written does not equal to given size.
}
function writeToFile(const name: wString; buf: pointer; size: unsigned; pos: unsigned = 0; posMode: unsigned = FILE_END): int; overload;
{*
	Writes data into a file specified by name at specified position.
	Creates the file if it does not exists.

	@return 0 if operation has been completed successfully, or buf = nil, or size &lt; 1;
	@return -1 if no file name was given;
	@return -2 if there was some error in opening the file;
	@return -3 if operation has been failed for some reason;
	@return -4 if number of bytes written does not equal to given size.
}
function writeToFile(const name: wString; const buf: aString; pos: unsigned = 0; posMode: unsigned = FILE_END): int; overload;
{*
	Writes data into a file specified by handle at specified position.
	Creates the file if it does not exists.

	@return 0 if operation has been completed successfully, or buf = nil, or size &lt; 1;
	@return -1 if no file name was given;
	@return -2 if there was some error in opening the file;
	@return -3 if operation has been failed for some reason;
	@return -4 if number of bytes written does not equal to given size.
}
function writeToFile(handle: tHandle; buf: pointer; size: unsigned; pos: unsigned = 0; posMode: unsigned = FILE_CURRENT): int; overload;
{*
	Writes data into a file specified by handle at specified position.
	Creates the file if it does not exists.

	@return 0 if operation has been completed successfully, or buf = nil, or size &lt; 1;
	@return -1 if no file name was given;
	@return -2 if there was some error in opening the file;
	@return -3 if operation has been failed for some reason;
	@return -4 if number of bytes written does not equal to given size.
}
function writeToFile(handle: tHandle; const buf: aString; pos: unsigned = 0; posMode: unsigned = FILE_CURRENT): int; overload;
{$IFDEF VC25_OVERLAPPED }
/// overlapped write
function write2file(handle: tHandle; var offset: int; buf: pointer; len: unsigned): bool;
{$ENDIF VC25_OVERLAPPED }

{*
	Reads data from a file specified by name at specified position.

	@param name File name.
	@param buf Buffer to place data into.
	@param size Number of bytes to read. Buffer must be at least of that size.<BR>Will be set to number of bytes actually read from the file, or to 0 if some error has occured.
	@param pos Offset in file to read data from (actual offset depends on posMode).
	@param posMode How to calculate the real offset in the file (default is FILE_BEGIN, refer to MSDN for mode details).

	@return 0 if operation has been completed successfully, or buf = nil, or size &lt; 1;
	@return -1 if no file name was given;
	@return -2 if there was an error in opening the file;
	@return -3 if operation has been failed for some reason;
	@return -4 if number of bytes read does not equal to given size (file is too short). Not a fatal error in most cases.
}
function readFromFile(const name: wString; buf: pointer; var size: unsigned; pos: unsigned = 0; posMode: unsigned = FILE_BEGIN): int; overload;
{*
	Reads data from a file specified by name at specified position.

	@param name File name.
	@param pos Offset in file to read data from (actual offset depends on posMode).
	@param posMode How to calculate the real offset in the file (default is FILE_BEGIN, refer to MSDN for mode details).
	@param len How many bytes to read (default is 0, means read all the file).

	@return Read data as string of bytes.
}
function readFromFile(const name: wString; pos: unsigned = 0; posMode: unsigned = FILE_BEGIN; len: int64 = 0): aString; overload;
{*
	Same as readFromFile() but return wideString.
}
//function readFromFileW(const name: wString; pos: unsigned = 0; posMode: unsigned = FILE_BEGIN; len: int64 = 0): wString;
{*
	Reads data from a file specified by handle at specified position.

	@param handle File handle.
	@param buf Buffer to place data into.
	@param size Number of bytes to read. Buffer must be at least of that size.<BR>Will be set to number of bytes actually read from the file, or to 0 if some error has occured.
	@param pos Offset in file to read data from (actual offset depends on posMode).
	@param posMode How to calculate the real offset in the file (default is FILE_CURRENT, refer to MSDN for mode details).

	@return 0 if operation has been completed successfully, or buf = nil, or size &lt; 1;
	@return -1 if no file name was given;
	@return -2 if there was an error in opening the file;
	@return -3 if operation has been failed for some reason;
	@return -4 if number of bytes read does not equal to given size (file is too short). Not a fatal error in most cases.
}
function readFromFile(handle: tHandle; buf: pointer; var size: unsigned; pos: unsigned = 0; posMode: unsigned = FILE_CURRENT): int; overload;
{*
	@return file size in bytes, or -1 if file does not exists.
}
function fileSize(const name: wString): int64; overload;
{*
	@return file size in bytes, or -1 if file does not exists.
}
function fileSize(handle: tHandle): int64; overload;
{*
	Seeks the file to specified position.

	@return Resulting file position or -1 if file handle is invalid.
}
function fileSeek(handle: tHandle; pos: int = 0; posMode: unsigned = FILE_BEGIN): int;
{*
	Renames the file.
}
function fileMove(const oldName, newName: wString): bool;
{*
	Copies the file content to a new file.
}
function fileCopy(const oldName, newName: wString; failIfExists: bool): bool;
{*
	Removes the file.
}
function fileDelete(const fileName: wString): bool;
{*
	Calculates CRC32 checksum of a file.
}
function fileChecksum(f: tHandle; crc: uint32 = $FFFFFFFF): uint32; overload;
{*
	Calculates CRC32 checksum of a file.
}
function fileChecksum(const fileName: wString): uint32; overload;
{*
	Returns file modification time.
}
function fileModificationDateTime(const fileName: wString; useLocalTime: bool = true): SYSTEMTIME; overload;
{*
	Returns file modification time.
}
function fileModificationDateTime(f: tHandle; useLocalTime: bool = true): SYSTEMTIME; overload;
{*
	Returns file creation time.
}
function fileCreationDateTime(const fileName: wString; useLocalTime: bool = true): SYSTEMTIME; overload;
{*
  	Returns file creation time.
}
function fileCreationDateTime(f: tHandle; useLocalTime: bool = true): SYSTEMTIME; overload;


{*
	Returns True if specified directory exists.
}
function directoryExists(const name: wString): bool;

{*
  	Ensures that specified path exists. Recursively creates directories as required.
}
function forceDirectories(const path: wString): bool;

{*
	Returns file path (without file name).
}
function extractFilePath(const fileName: wString): wString;

{*
	Returns file name (without file path).
}
function extractFileName(const fileName: wString): wString;

{*
	Replaces the file extension with given one.
}
function changeFileExt(const fileName: wString; const ext: wString = '.txt'): wString;
{*
	Expands short file name to long one.
}
function GetLongPathName(shortPathName: wString): wString;


const
  { Browsing for directory. }

  {$EXTERNALSYM BIF_RETURNONLYFSDIRS}
  BIF_RETURNONLYFSDIRS   = $0001;  /// For finding a folder to start document searching
  {$EXTERNALSYM BIF_DONTGOBELOWDOMAIN}
  BIF_DONTGOBELOWDOMAIN  = $0002;  /// For starting the Find Computer
  {$EXTERNALSYM BIF_STATUSTEXT}
  BIF_STATUSTEXT         = $0004;
  {$EXTERNALSYM BIF_RETURNFSANCESTORS}
  BIF_RETURNFSANCESTORS  = $0008;
  {$EXTERNALSYM BIF_EDITBOX}
  BIF_EDITBOX            = $0010;
  {$EXTERNALSYM BIF_VALIDATE}
  BIF_VALIDATE           = $0020;  /// insist on valid result (or CANCEL)
  {$EXTERNALSYM BIF_NEWDIALOGSTYLE}
  BIF_NEWDIALOGSTYLE     = $0040;
  {$EXTERNALSYM BIF_BROWSEINCLUDEURLS}
  BIF_BROWSEINCLUDEURLS  = $0080;

  {$EXTERNALSYM BIF_BROWSEFORCOMPUTER}
  BIF_BROWSEFORCOMPUTER  = $1000;  /// Browsing for Computers
  {$EXTERNALSYM BIF_BROWSEFORPRINTER}
  BIF_BROWSEFORPRINTER   = $2000;  /// Browsing for Printers
  {$EXTERNALSYM BIF_BROWSEINCLUDEFILES}
  BIF_BROWSEINCLUDEFILES = $4000;  /// Browsing for Everything
  {$EXTERNALSYM BIF_SHAREABLE}
  BIF_SHAREABLE          = $8000;

  {$EXTERNALSYM BIF_USENEWUI}
	BIF_USENEWUI = BIF_NEWDIALOGSTYLE or BIF_EDITBOX;


  { message from browser }

  {$EXTERNALSYM BFFM_INITIALIZED}
  BFFM_INITIALIZED       = 1;
  {$EXTERNALSYM BFFM_SELCHANGED}
  BFFM_SELCHANGED        = 2;
  {$EXTERNALSYM BFFM_VALIDATEFAILEDA}
  BFFM_VALIDATEFAILEDA   = 3;   /// lParam:szPath ret:1(cont),0(EndDialog)
  {$EXTERNALSYM BFFM_VALIDATEFAILEDW}
  BFFM_VALIDATEFAILEDW   = 4;   /// lParam:wzPath ret:1(cont),0(EndDialog) 

  { messages to browser }

  {$EXTERNALSYM WM_USER}
  WM_USER             = $0400;

  {$EXTERNALSYM BFFM_SETSTATUSTEXTA}
  BFFM_SETSTATUSTEXTA         = WM_USER + 100;
  {$EXTERNALSYM BFFM_ENABLEOK}
  BFFM_ENABLEOK               = WM_USER + 101;
  {$EXTERNALSYM BFFM_SETSELECTIONA}
  BFFM_SETSELECTIONA          = WM_USER + 102;
  {$EXTERNALSYM BFFM_SETSELECTIONW}
  BFFM_SETSELECTIONW          = WM_USER + 103;
  {$EXTERNALSYM BFFM_SETSTATUSTEXTW}
  BFFM_SETSTATUSTEXTW         = WM_USER + 104;

  {$EXTERNALSYM BFFM_VALIDATEFAILED}
  BFFM_VALIDATEFAILED     = BFFM_VALIDATEFAILEDA;
  {$EXTERNALSYM BFFM_SETSTATUSTEXT}
  BFFM_SETSTATUSTEXT      = BFFM_SETSTATUSTEXTA;
  {$EXTERNALSYM BFFM_SETSELECTION}
  BFFM_SETSELECTION       = BFFM_SETSELECTIONA;

type
{$IFDEF FPC }
{$ELSE }
  {*
	TSHItemID -- Item ID
  }
  PSHItemID = ^TSHItemID;
  {$EXTERNALSYM _SHITEMID}
  _SHITEMID = record
    cb: Word;                         /// Size of the ID (including cb itself)
    abID: array[0..0] of Byte;        /// The item ID (variable length)
  end;
  TSHItemID = _SHITEMID;
  {$EXTERNALSYM SHITEMID}
  SHITEMID = _SHITEMID;


  {*
	TItemIDList -- List if item IDs (combined with 0-terminator)
  }
  PItemIDList = ^TItemIDList;
  {$EXTERNALSYM _ITEMIDLIST}
  _ITEMIDLIST = record
     mkid: TSHItemID;
   end;
  TItemIDList = _ITEMIDLIST;
  {$EXTERNALSYM ITEMIDLIST}
  ITEMIDLIST = _ITEMIDLIST;

  {$EXTERNALSYM BFFCALLBACK}
  BFFCALLBACK = function(wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): integer stdcall;

{$ENDIF FPC }
  //
  TFNBFFCallBack = type BFFCALLBACK;

  //
	PBrowseInfoA = ^TBrowseInfoA;
  PBrowseInfoW = ^TBrowseInfoW;
{$IFDEF FPC }
{$ELSE }
  PBrowseInfo = PBrowseInfoA;
{$ENDIF FPC }

  {$EXTERNALSYM _browseinfoA}
  _browseinfoA = record
    hwndOwner: HWND;
    pidlRoot: PItemIDList;
    pszDisplayName: paChar;  /// Return display name of item selected.
    lpszTitle: paChar;      /// text to go in the banner over the tree.
    ulFlags: UINT;           /// Flags that control the return stuff.
    lpfn: TFNBFFCallBack;
    lParam: LPARAM;          /// extra info that's passed back in callbacks.
    iImage: Integer;         /// output var: where to return the Image index.
  end;
  {$EXTERNALSYM _browseinfoW}
  _browseinfoW = record
    hwndOwner: HWND;
    pidlRoot: PItemIDList;
    pszDisplayName: pwChar;  /// Return display name of item selected.
    lpszTitle: pwChar;      /// text to go in the banner over the tree.
    ulFlags: UINT;           /// Flags that control the return stuff.
    lpfn: TFNBFFCallBack;
    lParam: LPARAM;          /// extra info that's passed back in callbacks.
    iImage: Integer;         /// output var: where to return the Image index.
  end;

  TBrowseInfoA = _browseinfoA;
  {$EXTERNALSYM BROWSEINFOA}
  BROWSEINFOA = _browseinfoA;
  TBrowseInfoW = _browseinfoW;
  {$EXTERNALSYM BROWSEINFOW}
  BROWSEINFOW = _browseinfoW;

{$IFDEF FPC }
{$ELSE }
  {$EXTERNALSYM _browseinfo}
  _browseinfo = _browseinfoA;
  TBrowseInfo = TBrowseInfoA;
  {$EXTERNALSYM BROWSEINFO}
  BROWSEINFO = BROWSEINFOA;
{$ENDIF FPC }

{$IFDEF FPC }
{$ELSE }

  {*
	Record for returning strings from IShellFolder member functions.
  }
  PSTRRet = ^TStrRet;
  {$EXTERNALSYM _STRRET}
  _STRRET = record
     uType: UINT;              { One of the STRRET_* values }
     case Integer of
       0: (pOleStr: LPWSTR);                    { must be freed by caller of GetDisplayNameOf }
       1: (pStr: LPSTR);                        { NOT USED }
       2: (uOffset: UINT);                      { Offset into SHITEMID (ANSI) }
       3: (cStr: array[0..MAX_PATH-1] of aChar); { Buffer to fill in }
    end;
  TStrRet = _STRRET;
  {$EXTERNALSYM STRRET}
  STRRET = _STRRET;

{$ENDIF FPC }

  {$EXTERNALSYM IMalloc}
  IMalloc = interface(IUnknown)
    ['{00000002-0000-0000-C000-000000000046}']
    function Alloc(cb: Longint): Pointer; stdcall;
    function Realloc(pv: Pointer; cb: Longint): Pointer; stdcall;
    procedure Free(pv: Pointer); stdcall;
		function GetSize(pv: Pointer): Longint; stdcall;
    function DidAlloc(pv: Pointer): Integer; stdcall;
    procedure HeapMinimize; stdcall;
  end;


  {$EXTERNALSYM IEnumIDList}
  IEnumIDList = interface(IUnknown)
    ['{000214F2-0000-0000-C000-000000000046}']
    function Next(celt: ULONG; out rgelt: PItemIDList; var pceltFetched: ULONG): HResult; stdcall;
    function Skip(celt: ULONG): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out ppenum: IEnumIDList): HResult; stdcall;
  end;


  {$EXTERNALSYM IShellFolder}
  IShellFolder = interface(IUnknown)
    ['{000214E6-0000-0000-C000-000000000046}']
    function ParseDisplayName(hwndOwner: HWND; pbcReserved: Pointer; lpszDisplayName: pwChar; out pchEaten: ULONG; out ppidl: PItemIDList; var dwAttributes: ULONG): HResult; stdcall;
    function EnumObjects(hwndOwner: HWND; grfFlags: DWORD; out EnumIDList: IEnumIDList): HResult; stdcall;
    function BindToObject(pidl: PItemIDList; pbcReserved: Pointer; const riid: TGUID; out ppvOut): HResult; stdcall;
    function BindToStorage(pidl: PItemIDList; pbcReserved: Pointer; const riid: TGUID; out ppvObj): HResult; stdcall;
    function CompareIDs(lParam: LPARAM; pidl1, pidl2: PItemIDList): HResult; stdcall;
    function CreateViewObject(hwndOwner: HWND; const riid: TGUID; out ppvOut): HResult; stdcall;
    function GetAttributesOf(cidl: UINT; var apidl: PItemIDList; var rgfInOut: UINT): HResult; stdcall;
    function GetUIObjectOf(hwndOwner: HWND; cidl: UINT; var apidl: PItemIDList; const riid: TGUID; prgfInOut: Pointer; out ppvOut): HResult; stdcall;
    function GetDisplayNameOf(pidl: PItemIDList; uFlags: DWORD; var lpName: TStrRet): HResult; stdcall;
    function SetNameOf(hwndOwner: HWND; pidl: PItemIDList; lpszName: pwChar; uFlags: DWORD; var ppidlOut: PItemIDList): HResult; stdcall;
  end;


{$EXTERNALSYM SHGetMalloc }
function SHGetMalloc(var ppMalloc: IMalloc): HResult; stdcall;
{$EXTERNALSYM SHGetDesktopFolder }
function SHGetDesktopFolder(var ppshf: IShellFolder): HResult; stdcall;
{$EXTERNALSYM SHBrowseForFolderA }
function SHBrowseForFolderA(var lpbi: TBrowseInfoA): PItemIDList; stdcall;
{$EXTERNALSYM SHBrowseForFolderW }
function SHBrowseForFolderW(var lpbi: TBrowseInfoW): PItemIDList; stdcall;
{$EXTERNALSYM SHGetPathFromIDListA}
function SHGetPathFromIDListA(pidl: PItemIDList; pszPath: paChar): BOOL; stdcall;
{$EXTERNALSYM SHGetPathFromIDListW}
function SHGetPathFromIDListW(pidl: PItemIDList; pszPath: pwChar): BOOL; stdcall;

{*
	Opens directory selection dialog.

	@param caption Dialog caption.
	@param root Root folder to build tree from.
	@param directory Start brofsing from this directory ('' = root). Returns selected directory if selection was successfull.
	@param handle Handle of parent window.
	@param flags Flags for the dialog.
	
	@return True if selection was successfull.
}
function guiSelectDirectory(const caption, root: wString; var directory: wString; handle: hWnd = 0; flags: uint = BIF_RETURNONLYFSDIRS): bool;


{*
  Ensures you can safely add a file name to the given path. Adds '\' character to the end of path as necessary.
  <pre>
  Exaples:
    C:\temp\ =&gt; C:\temp\
    C:\temp =&gt; C:\temp\
    C:\ =&gt; C:\
    C: =&gt; C:
    C:\temp/ =&gt; C:\temp/
  </pre>
}
function addBackSlash(const path: wString): wString;

{*
	Returns temporary file name.
}
function getTemporaryFileName(const prefix: wString = 'una'): wString;

const
  {$EXTERNALSYM REGSTR_PATH_EXPLORER}
  REGSTR_PATH_EXPLORER        = 'Software\Microsoft\Windows\CurrentVersion\Explorer';

{ registry entries for special paths are kept in : }

  {$EXTERNALSYM REGSTR_PATH_SPECIAL_FOLDERS}
  REGSTR_PATH_SPECIAL_FOLDERS   = REGSTR_PATH_EXPLORER + '\Shell Folders';

  {$EXTERNALSYM CSIDL_DESKTOP}
  CSIDL_DESKTOP                       = $0000;
  {$EXTERNALSYM CSIDL_INTERNET}
  CSIDL_INTERNET                      = $0001;
  {$EXTERNALSYM CSIDL_PROGRAMS}
  CSIDL_PROGRAMS                      = $0002;
  {$EXTERNALSYM CSIDL_CONTROLS}
  CSIDL_CONTROLS                      = $0003;
  {$EXTERNALSYM CSIDL_PRINTERS}
  CSIDL_PRINTERS                      = $0004;
  {$EXTERNALSYM CSIDL_PERSONAL}
  CSIDL_PERSONAL                      = $0005;
  {$EXTERNALSYM CSIDL_FAVORITES}
  CSIDL_FAVORITES                     = $0006;
  {$EXTERNALSYM CSIDL_STARTUP}
  CSIDL_STARTUP                       = $0007;
  {$EXTERNALSYM CSIDL_RECENT}
  CSIDL_RECENT                        = $0008;
  {$EXTERNALSYM CSIDL_SENDTO}
  CSIDL_SENDTO                        = $0009;
  {$EXTERNALSYM CSIDL_BITBUCKET}
  CSIDL_BITBUCKET                     = $000a;
  {$EXTERNALSYM CSIDL_STARTMENU}
  CSIDL_STARTMENU                     = $000b;
  {$EXTERNALSYM CSIDL_DESKTOPDIRECTORY}
  CSIDL_DESKTOPDIRECTORY              = $0010;
  {$EXTERNALSYM CSIDL_DRIVES}
  CSIDL_DRIVES                        = $0011;
  {$EXTERNALSYM CSIDL_NETWORK}
  CSIDL_NETWORK                       = $0012;
  {$EXTERNALSYM CSIDL_NETHOOD}
  CSIDL_NETHOOD                       = $0013;
  {$EXTERNALSYM CSIDL_FONTS}
  CSIDL_FONTS                         = $0014;
  {$EXTERNALSYM CSIDL_TEMPLATES}
  CSIDL_TEMPLATES                     = $0015;
  {$EXTERNALSYM CSIDL_COMMON_STARTMENU}
  CSIDL_COMMON_STARTMENU              = $0016;
  {$EXTERNALSYM CSIDL_COMMON_PROGRAMS}
  CSIDL_COMMON_PROGRAMS               = $0017;
  {$EXTERNALSYM CSIDL_COMMON_STARTUP}
  CSIDL_COMMON_STARTUP                = $0018;
  {$EXTERNALSYM CSIDL_COMMON_DESKTOPDIRECTORY}
  CSIDL_COMMON_DESKTOPDIRECTORY       = $0019;
  {$EXTERNALSYM CSIDL_APPDATA}
  CSIDL_APPDATA                       = $001a;
  {$EXTERNALSYM CSIDL_PRINTHOOD}
  CSIDL_PRINTHOOD                     = $001b;
  {$EXTERNALSYM CSIDL_LOCAL_APPDATA}
  CSIDL_LOCAL_APPDATA                 = $001c;
  {$EXTERNALSYM CSIDL_ALTSTARTUP}
  CSIDL_ALTSTARTUP                    = $001d;         // DBCS
  {$EXTERNALSYM CSIDL_COMMON_ALTSTARTUP}
  CSIDL_COMMON_ALTSTARTUP             = $001e;         // DBCS
  {$EXTERNALSYM CSIDL_COMMON_FAVORITES}
  CSIDL_COMMON_FAVORITES              = $001f;
  {$EXTERNALSYM CSIDL_INTERNET_CACHE}
  CSIDL_INTERNET_CACHE                = $0020;
  {$EXTERNALSYM CSIDL_COOKIES}
  CSIDL_COOKIES                       = $0021;
  {$EXTERNALSYM CSIDL_HISTORY}
  CSIDL_HISTORY                       = $0022;
  {$EXTERNALSYM CSIDL_PROFILE}
  CSIDL_PROFILE                       = $0028; { USERPROFILE }
  {$EXTERNALSYM CSIDL_CONNECTIONS}
  CSIDL_CONNECTIONS                   = $0031; { Network and Dial-up Connections }
  {$EXTERNALSYM CSIDL_COMMON_MUSIC}
  CSIDL_COMMON_MUSIC                  = $0035; { All Users\My Music }
  {$EXTERNALSYM CSIDL_COMMON_PICTURES}
  CSIDL_COMMON_PICTURES               = $0036; { All Users\My Pictures }
  {$EXTERNALSYM CSIDL_COMMON_VIDEO}
  CSIDL_COMMON_VIDEO                  = $0037; { All Users\My Video }
  {$EXTERNALSYM CSIDL_CDBURN_AREA}
  CSIDL_CDBURN_AREA                   = $003b; { USERPROFILE\Local Settings\Application Data\Microsoft\CD Burning }
  {$EXTERNALSYM CSIDL_COMPUTERSNEARME}
  CSIDL_COMPUTERSNEARME               = $003d; { Computers Near Me (computered from Workgroup membership) }
  {$EXTERNALSYM CSIDL_PROFILES}
  CSIDL_PROFILES                      = $003e;

  {$EXTERNALSYM CSIDL_COMMON_APPDATA}
  CSIDL_COMMON_APPDATA = $0023; { All Users\Application Data }
  {$EXTERNALSYM CSIDL_WINDOWS}
  CSIDL_WINDOWS = $0024; { GetWindowsDirectory() }
  {$EXTERNALSYM CSIDL_SYSTEM}
  CSIDL_SYSTEM = $0025; { GetSystemDirectory() }
  {$EXTERNALSYM CSIDL_PROGRAM_FILES}
  CSIDL_PROGRAM_FILES = $0026; { C:\Program Files }
  {$EXTERNALSYM CSIDL_MYPICTURES}
  CSIDL_MYPICTURES = $0027; { My Pictures, new for Win2K }
  {$EXTERNALSYM CSIDL_PROGRAM_FILES_COMMON}
  CSIDL_PROGRAM_FILES_COMMON = $002b; { C:\Program Files\Common }
  {$EXTERNALSYM CSIDL_COMMON_DOCUMENTS}
  CSIDL_COMMON_DOCUMENTS = $002e; { All Users\Documents }

  {$EXTERNALSYM CSIDL_FLAG_CREATE}
  CSIDL_FLAG_CREATE = $8000; { new for Win2K, or this in to force creation of folder }

  {$EXTERNALSYM CSIDL_COMMON_ADMINTOOLS}
  CSIDL_COMMON_ADMINTOOLS = $002f; { All Users\Start Menu\Programs\Administrative Tools }

  {$EXTERNALSYM CSIDL_ADMINTOOLS}
  CSIDL_ADMINTOOLS = $0030; { <user name>\Start Menu\Programs\Administrative Tools }


{$EXTERNALSYM SHGetSpecialFolderPathA }
{$EXTERNALSYM SHGetSpecialFolderPathW }
function SHGetSpecialFolderPathA(owner: HWND; lpszPath: paChar; nFolder: int; fCreate: BOOL): BOOL; stdcall;
function SHGetSpecialFolderPathW(owner: HWND; lpszPath: pwChar; nFolder: int; fCreate: BOOL): BOOL; stdcall;

{*
	Returns special folder path.
}
function getSpecialFolderPath(nFolder: int; owner: hWnd = 0; doCreate: bool = false): wString;
{*
	Returns Application Data folder path.
}
function getAppDataFolderPath(owner: hWnd = 0; doCreate: bool = false): wString;


{*
	@return host name.
}
function hostName(): wString;


type
  {*
	Callback routine for findFiles().

	@return True if process should continue.
  }
  proc_ffcallback = function(sender: pointer; const path: wString; const fdw: WIN32_FIND_DATAW): bool;

{*
	Finds all files according to path and mask, optionally travelling in subdirs.
	For each file or subfolder found it calls the specified callback routime.
}
procedure findFiles(const path, mask: wString; callback: proc_ffcallback; includeSubfolders: bool = false; sender: pointer = nil);

{*
	Removes all files in a folder (and optionally subfolders) according to file mask specified.
	All empty subfolders may be removed too, making it easy to clean up all contect of a folder.
	SFONLY and omask are internal parameters and must not be specified.
}
function folderRemoveFiles(const path: wString; includeSubfolders: bool = false; const mask: wString = '*.*'; removeSubfoldersAsWell: bool = false; SFONLY: bool = false; const omask: wString = ''): bool;

{*
	Returns True if folder was successfully removed. Folder must not contain subfolders or files.
	Use folderRemoveFiles() to remove subfolders and/or files.
}
function folderRemove(const path: wString): bool;


// -- PARAMS --

{*
	Returns specified (by index) command line parameter as wide string.
}
function paramStrW(index: unsigned): wString;

{*
	Returns True if command line contains given switch.
}
function hasSwitch(const name: string; caseSensitive: bool = false): bool; overload;
{*
	Returns value of a given command line switch.
}
function switchValue(const name: string; caseSensitive: bool = false; defValue: int = 0): int; overload;
function switchValue(const name: string; caseSensitive: bool = false; const defValue: string = ''): string; overload;


// -- DISK --

{*
	index means:
	0 - FreeBytesAvailable
	1 - TotalNumberOfBytes
	2 - TotalNumberOfFreeBytes
}
function getDiskSpace(const path: wString; index: int): int64;


// -- FORMAT CONVERSIONS --

{*
	Converts boolean value to integer. Returns 0 if value = false and 1 otherwise.
}
function bool2int(value: bool): int;
{*
	Converts integer value to boolean. Returns false if value = 0 and true otherwise.
}
function int2bool(value: int): bool;
{*
	Converts boolean value to string. Returns '0' if value = false and '1' otherwise.
}
function bool2str(value: bool): string;
{*
	Converts boolean value to string. Returns 'false' if value = false and 'true' otherwise.
}
function bool2strStr(value: bool): string;

{$IFNDEF CPU64 }
{*
	Converts integer value to a string.
	For example, when split = 3 and splitchar is ' ', instead of '12345' this function returns '12 345'.

	@param base base for conversion (10 or 16 for example, max is 69).
	@param split if split > 0, the result will be divided on groups of digits, with at least split digits in every group.
	@param splitchar delimiter char used to separate one group from other (when split > 0).
}
function int2str(value: int; base: unsigned = 10; split: unsigned = 0; splitchar: char = ' '): string; overload;
{$ENDIF CPU64 }
{*
	Converts int64 value to a string.
	See int2str(int) for description of other parameters.
}
function int2str(const value: int64; base: unsigned = 10; split: unsigned = 0; splitchar: char = ' '): string; overload;
{*
	Converts unsigned value to a string.
	See int2str(int) for description of other parameters.
}
function int2str(value: unsigned; base: unsigned = 10; split: unsigned = 0; splitchar: char = ' '): string; overload;
{*
	Converts word value to string.
	See int2str(int) for description of other parameters.
}
function int2str(value: word; base: unsigned = 10; split: unsigned = 0; splitchar: char = ' '): string; overload;
{*
	Converts array of integer values into a comma-separated string.
}
function intArray2str(value: pInt32Array): string;
{*
	Converts string value to a boolean value.

	@return False if value = '0' and true otherwise.
}
function str2bool(const value: string; defValue: bool = false): bool;
{*
	Converts string value to boolean.

	@return true if value = 'true', false if value = 'false' and defValue otherwise.
}
function strStr2bool(const value: string; defValue: bool = false): bool;
{*
	Converts string value to byte.

	@return defValue if conversion fails.
}
function str2intByte(const value: string; defValue: byte = 0; base: unsigned = 10; ignoreTrails: bool = false): byte;
{*
	Converts string value to integer.

	@return defValue if conversion fails.
}
function str2intInt(const value: string; defValue: int = 0; base: unsigned = 10; ignoreTrails: bool = false): int;
{*
	Converts string value to unsigned.

	@return defValue if conversion fails.
}
function str2intUnsigned(const value: string; defValue: unsigned = 0; base: unsigned = 10; ignoreTrails: bool = false): unsigned;


{$IFDEF __SYSUTILS_H_ }

{*
	Converts float value to a string. Uses SysUtils.floatToStrF() routine.
}
function float2str(const value: extended): string;
{*
	Converts string to a float value. Uses SysUtils.strToFloat() routine.
}
function str2float(const value: string): extended;

{$ELSE }

{*
	Simple version of float2str()
}
function float2str(const value: extended): string;

{$ENDIF __SYSUTILS_H_ }

{*
	Converts string value to int64.

	@return defValue if conversion fails.
}
function str2intInt64(const value: string; defValue: int64 = 0; base: unsigned = 10; ignoreTrails: bool = false): int64; overload;
{*
	Converts string value to int64.

	@return defValue if conversion fails.
}
function str2intInt64(value: pChar; maxLen: int; defValue: int64 = 0; base: unsigned = 10; ignoreTrails: bool = false): int64; overload;
{*
	Converts comma-separated string into array of integer values.

	@param value Comma-separated string.
	@param subLevel Internal, do not specify.

	@return Pointer to new allocated array of integers (or nil).
}
function str2intArray(const value: string; subLevel: int = 0): pInt32Array;

{*
	Returns new GUID.
}
function newGUID(): string;
{*
	Compares two GUIDs.
}
function sameGUIDs(const g1, g2: tGuid): bool;

{*
	Converts milliseconds to days, hours, minutes, seconds and milliseconds.
}
procedure ms2time(ms: int64; out dd, hh, mm, ss, mss: unsigned);

{$IFDEF __SYSUTILS_H_ }
{$ELSE }

{*
  Encodes hours, minutes seconds and milliseconds to tDateTime value.
  Same as SysUtils.encodeTime() routine.
}
function encodeTime(hh, mm, ss, ms: unsigned): tDateTime;

{$ENDIF __SYSUTILS_H_ }

{*
	Converts milliseconds to tDateTime value
}
function ms2dateTime(ms: int64): tDateTime;
{*
	Converts tDateTime value into string. Uses base64encode() to encode dateTime value.
}
function dateTime2b64str(const dateTime: tDateTime): string;
{*
	Converts a string into tDateTime value. Uses base64dencode() to dencode date value.
}
function b64str2dateTime(const date: string; const defValue: tDateTime = 0): tDateTime;
{*
	Converts system time into a string.
}
function sysTime2str(time: pSYSTEMTIME = nil; const format: wString = ''; locale: LCID = LOCALE_USER_DEFAULT; flags: DWORD = LOCALE_NOUSEROVERRIDE or TIME_NOSECONDS): wString;
{*
	Converts system date into a string.
}
function sysDate2str(date: pSYSTEMTIME = nil; const format: wString = ''; locale: LCID = LOCALE_USER_DEFAULT; flags: DWORD = 0): wString;
{*
	Converts system date/time from UTC into a local system date/time.
}
function sysDateTime2localDateTime(const sysDate: SYSTEMTIME; out localDate: SYSTEMTIME): bool;
{*
	Returns current system time UTC timescale.
}
function nowUTC(): SYSTEMTIME;
{*
	Converts local system date/time into UTC system date/time.
}
function utc2local(const dateTime: SYSTEMTIME): SYSTEMTIME;
{*
	Returns number of full months passed between two dates.
}
function monthsPassed(const now, than: SYSTEMTIME): int;


{$IFDEF __SYSUTILS_H_ }
{$ELSE }

type
  // --  --
  tDayTable = array[1..12] of byte;

const
  // --  --
  monthDays: array [boolean] of tDayTable =
    ((31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31),
     (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31));

{*
  Returns true if specified year is leap.
  Same as SysUtils.isLeapYear() routine.
}
function isLeapYear(y: int): boolean;

{$ENDIF __SYSUTILS_H_ }

{*
  Converts value and total into percentage.
  For example, if value is 1, and total is 50 result will be 2.
}
function percent(value, total: unsigned): unsigned; overload;
{*
  Converts value and total into percentage.
  For example, if value is 10, and total is 50 result will be 20.
}
function percent(value, total: int64): int64; overload;


//	STRINGS

{*
  Trims the specified value by removing all control or space characters from left (beginning) and right (ending) of the string.
}
{$IFDEF __BEFORE_D6__ }
  // Delphi 4 and 5 gone ambiguous with wide/ansi strings
  // So we lost some functionality but avoid ambiguousness
{$ELSE }
function trimS(const value: string; left: bool = true; right: bool = true): string; overload;
{$ENDIF __BEFORE_D6__ }

{$IFDEF __BEFORE_DC__ }
function trimS(const value: wString; left: bool = true; right: bool = true): wString; overload;
{$ELSE }
function trimS(const value: aString; left: bool = true; right: bool = true): aString; overload;
{$ENDIF __BEFORE_DC__ }

{*
  Returns lower case of given char.
  <BR /><STRONG>NOTE</STRONG>: only Latin characters from ASCII table are converted.
  <BR />Example:
  <BR />A =&gt; a
  <BR />b =&gt; b
  <BR />3 =&gt; 3
}
function loCase(value: char): char; overload;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
{$IFDEF __BEFORE_DC__ }
function loCase(value: wChar): wChar; overload;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
{$ELSE }
function loCase(value: aChar): aChar; overload;
{$ENDIF __BEFORE_DC__ }

{*
  Returns upper case of given character.
  <BR /><STRONG>NOTE</STRONG>: only Latin characters from ASCII table are converted.
  <BR />Example:
  <BR />A =&gt; A
  <BR />b =&gt; B
  <BR />3 =&gt; 3
}
function upCase(value: char): char; overload;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
{$IFDEF __BEFORE_DC__ }
function upCase(value: wChar): wChar; overload;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
{$ELSE }
function upCase(value: aChar): aChar; overload;
{$ENDIF __BEFORE_DC__ }


{$IFDEF FPC }
  {$DEFINE NEED_CSTR_XXXX }
{$ENDIF FPC }

{$IFDEF __BEFORE_D7__ }
  {$DEFINE NEED_CSTR_XXXX }
{$ENDIF __BEFORE_D7__ }

{$IFDEF NEED_CSTR_XXXX }

const
  { Compare String Return Values }
  {$EXTERNALSYM CSTR_LESS_THAN}
  CSTR_LESS_THAN           = 1;             { string 1 less than string 2 }
  {$EXTERNALSYM CSTR_EQUAL}
  CSTR_EQUAL               = 2;             { string 1 equal to string 2 }
  {$EXTERNALSYM CSTR_GREATER_THAN}
  CSTR_GREATER_THAN        = 3;             { string 1 greater than string 2 }

{$ENDIF NEED_CSTR_XXXX }


{$IFDEF __SYSUTILS_H_ }
{$ELSE }

{*
  Converts all character in given string into upper case.
  Same as SysUtils.upperCase() routine.
}
function upperCase(const value: string): string; overload;
{*
  Converts all character in given string into lower case.
  <BR /><STRONG>NOTE</STRONG>: only Latin characters from ASCII table are converted.
  <BR />Example:
  <BR />Alek =&gt; alek
  <BR />bool =&gt; bool
  <BR />345 =&gt; 345
}
function lowerCase(const value: string): string; overload;

{$ENDIF __SYSUTILS_H_ }


{$IFDEF __BEFORE_DC__ }
  {$IFDEF __BEFORE_D6__ }
  {$ELSE }
    function lowerCase(const value: wString): wString; overload;
  {$ENDIF __BEFORE_D6__ }
{$ELSE }
  function lowerCase(const value: aString): aString; overload;
{$ENDIF __BEFORE_DC__ }

{$IFDEF __BEFORE_DC__ }
  {$IFDEF __BEFORE_D6__ }
  {$ELSE }
    function upperCase(const value: wString): wString; overload;
  {$ENDIF __BEFORE_D6__ }
{$ELSE }
  function upperCase(const value: aString): aString; overload;
{$ENDIF __BEFORE_DC__ }

{*
  Compares two strings with regard (ignoreCase = false) or not (ignoreCase = true) to the case of characters in the string. Returns:
  <UL>
    <LI>0 - strings are identical</LI>
    <LI>-1 - str1 is shorter or lower then str2</LI>
    <LI>+1 - str2 is shorter or lower then str1</LI>
  </UL>
  <BR /><STRONG>NOTE</STRONG>: only Latin characters from ASCII table are converted when ignoreCase = true.
}
function compareStr(const str1, str2: string; ignoreCase: bool = false): int; overload;
{$IFDEF __BEFORE_DC__ }
  {$IFDEF __BEFORE_D6__ }
  {$ELSE }
  function compareStr(const str1, str2: wString; ignoreCase: bool = false): int; overload;
  {$ENDIF __BEFORE_D6__ }
{$ELSE }
  function compareStr(const str1, str2: aString; ignoreCase: bool = false): int; overload;
{$ENDIF __BEFORE_DC__ }

{$IFDEF __BEFORE_D6__ }
  // Delphi 4 and 5 gone ambiguous with wide/ansi strings
  // So we lost some functionality but avoid ambiguousness
{$ELSE }
function sameString(const str1, str2: string; doTrim: bool = true): bool; overload;
{$ENDIF __BEFORE_D6__ }

{$IFDEF __BEFORE_DC__ }
  function sameString(const str1, str2: wString; doTrim: bool = true; locale: LCID = LOCALE_SYSTEM_DEFAULT): bool; overload;
{$ELSE }
  function sameString(const str1, str2: aString; doTrim: bool = true): bool; overload;
{$ENDIF __BEFORE_DC__ }

{*
  Adjusts a string length to the len value, by adding additional character at the beginning (left = true) or at the end (left = false) of the string.
}
function adjust(const value: string; len: int; fill: char = ' '; left: bool = true; truncate: bool = false): string; overload;
{$IFDEF __BEFORE_DC__ }
  function adjust(const value: wString; len: int; fill: wChar = ' '; left: bool = true; truncate: bool = false): wString; overload;
{$ELSE }
  function adjust(const value: aString; len: int; fill: aChar = ' '; left: bool = true; truncate: bool = false): aString; overload;
{$ENDIF __BEFORE_DC__ }


{*
  Returns a string containing specified number of specified character.
}
function padChar(pad: char; len: unsigned): string; overload;
{*
  Returns a string containing specified number of specified character.
}
{$IFDEF __BEFORE_DC__ }
  function padChar(pad: wChar; len: unsigned): wString; overload;
{$ELSE }
  function padChar(pad: aChar; len: unsigned): aString; overload;
{$ENDIF __BEFORE_DC__ }


{*
  Copies source string into dest pChat. dest must be large enough to store the source.
  You can limit the number of characters to copy with maxLen parameter.
  Returns dest.
}
function strCopy(dest, source: pChar; maxLen: int = -1): pChar; overload;
{$IFDEF __BEFORE_DC__ }
  function strCopy(dest, source: pwChar; maxLen: int = -1): pwChar; overload;
{$ELSE }
  function strCopy(dest, source: paChar; maxLen: int = -1): paChar; overload;
{$ENDIF __BEFORE_DC__ }


{*
  Copies source string into dest pChat. dest must be large enough to store the source.
  Returns dest.
}
function strCopy(dest: pChar; const source: string; maxLen: int = -1): pChar; overload;
{$IFDEF __BEFORE_DC__ }
  function strCopy(dest: pwChar; const source: wString; maxLen: int = -1): pwChar; overload;
{$ELSE }
  function strCopy(dest: paChar; const source: aString; maxLen: int = -1): paChar; overload;
{$ENDIF __BEFORE_DC__ }


{*
  Allocates new pChar value and copies the source string into it.
}
function strNew(const source: string): pChar; overload;
//
{$IFDEF __BEFORE_DC__ }
  {$IFDEF __BEFORE_D6__ }
  function strNewW(const source: wString): pwChar;
  {$ELSE }
  function strNew(const source: wString): pwChar; overload;
  {$ENDIF __BEFORE_D6__ }
{$ELSE }
  function strNew(const source: aString): paChar; overload;
{$ENDIF __BEFORE_DC__ }

{*
  Returns number of chars being copied.
}
function str2array(const src: string; var A: array of char): int; {$IFDEF __BEFORE_D6__ }{$ELSE }overload;{$ENDIF __BEFORE_D6__ }
{$IFDEF __BEFORE_DC__ }
  {$IFDEF __BEFORE_D6__ }
    function str2arrayW(const src: wString; var A: array of wChar): int;
  {$ELSE }
    function str2array(const src: wString; var A: array of wChar): int; overload;
  {$ENDIF __BEFORE_D6__ }
{$ELSE }
  function str2array(const src: aString; var A: array of aChar): int; overload;
{$ENDIF __BEFORE_DC__ }


function array2str(const A: array of char; out value: string; startPos: int = low(int); length: int = -1): int; overload;
{$IFDEF __BEFORE_DC__ }
function array2str(const A: array of wChar; out value: wString; startPos: int = low(int); length: int = -1): int; overload;
{$ELSE }
function array2str(const A: array of aChar; out value: aString; startPos: int = low(int); length: int = -1): int; overload;
{$ENDIF __BEFORE_DC__ }

{*
  If maxArrayLength is specified, assumed that it includes the last NULL character.
  Returns number of wide chars being copied.
}
function array2str(const A: array of wChar; out value: wString; maxArrayLength: int = -1): int; overload;

{*
  Allocates memory for a new string.
}
function strAllocA(size: uint): paChar;
{*
  Deallocates memory taken by a string.

  Do not mix SysUtils.strNew() and unaUtils.strDispose().
}
function strDisposeA(str: paChar): bool;
function strDisposeW(str: pwChar): bool;
{*
  Returns length of a string.
}
function strLenA(str: paChar): unsigned;
{*
  Allocates memory for a new string. Use unaUtils.strDispose() to release the memory.
}
function strNewA(str: paChar): paChar;
{*
  Scans the src string for specified character.
  Returns pointer on position in the string where this character was found, or nil otherwise.
}
function strScanA(const str: paChar; chr: aChar): paChar;
{
}
function strPosA(const strSource, strToFind: paChar): paChar;
{*
  Returns position (starting from 1) in the s where one of the characters given in delimiters was found.
  Search is performed from the end of string. Returns length of s if no characters were found.
}
function lastDelimiter(const delimiters, s: wString): int;

{*
  Makes value safe to pass as "plain" string, by escaping special characters with "/" symbol. Examples:
  <UL>
	<LI>"Lake"#9"Una" -- "Lake/tUna"</LI>
	<LI>"Line1"#13#10"Line2" -- "Line1/r/nLine2"</LI>
	<LI>"C:\TEMP/" -- "C:\TEMP//"</LI>
	<LI>"PAGE"#12"FEED" -- "PAGE/012FEED"</LI>
  </UL>
}
function strEscape(const value: aString; const specialCare: aString = ''): aString;

{*
  Converts "escaped" value back to "plain" string. Examples:
  <UL>
	<LI>"Lake/tUna" -- "Lake"#9"Una"</LI>
	<LI>"Line1/r/nLine2" -- "Line1"#13#10"Line2"</LI>
	<LI>"C:\TEMP//" -- "C:\TEMP/"</LI>
	<LI>"PAGE/012FEED" -- "PAGE"#12"FEED"</LI>
  </UL>
}
function strUnescape(const value: aString): aString;

{*
  //
}
function htmlEscape(const value: aString; strict: bool = true): aString;

{*
  //
}
function urlEncode(const value: aString): aString;
function urlDecode(const value: aString): aString;

{*
  Substitues variable fields in the template with given values. Example:
  <BR />templ = "Hello from %name% %last name%, take the 10%% of text."
  <BR />vars = "name"#9"Lake"#10"last name"#9"Una"
  <BR />result = "Hello from Lake Una, take the 10% of text."
  <BR />&nbsp;
  <P />Use the strEscape() function to ensure there are no #9 or #10 characters in the values.
}
function formatTemplate(const templ: aString; const vars: aString; unescapeVars: bool = true): aString;
{*
}
function nextToken(const text: wString; var startPos: int): wString;
{*
  Returns number of tokens replaced.
}
function replaceTokens(var text: aString; const tokens: aString): int; overload;
function replaceTokens(var text: aString; const tokens: aString; var careSelStart: int): int; overload;
function replaceTokens(var text: wString; const tokens: wString; var careSelStart: int): int; overload;

{*
  Returns integer parameter value (or defValue);

  str must have the following format:

    param1=value1#9param2=value2
}
function getIntValueFromStr(const str, paramName: string; defValue: int): int;


{*
  Wrapper for MessageBox() function
}
function guiMessageBox(owner: hWnd; const message, title: wString; flags: int = MB_OK): int; overload;
function guiMessageBox(const message, title: wString; flags: int = MB_OK; owner: hWnd = 0): int; overload;

{$EXTERNALSYM ShellAboutA}
function ShellAboutA(Wnd: HWND; szApp, szOtherStuff: paChar; Icon: HICON): Integer; stdcall;
{$EXTERNALSYM ShellAboutW}
function ShellAboutW(Wnd: HWND; szApp, szOtherStuff: pwChar; Icon: HICON): Integer; stdcall;

{*
  Wrapper for ShellAbout function
}
function guiAboutBox(const appName, otherStuff: wString; handle: tHandle = 0; icon: hIcon = $FFFFFFFF): int;

//	DEBUG

{*
  Returns name of executable module with given extension.
}
function getModuleFileNameExt(const ext: wString): wString;
{*
  Produces file name with the same path as executable module.
}
function getModulePathName(const fileName: wString = ''): wString;


type
  // --  --
  unaInfoMessage_logTimeModeEnum = (unaLtm_default, unaLtm_none, unaLtm_date, unaLtm_time, unaLtm_dateTime, unaLtm_timeDelta, unaLtm_dateTimeDelta, unaLtm_dateTimeDelta64);

  {*
    This procedure type is used by infoMessage() routine.

    @param message Message to be logged/displayed.
  }
  infoMessageProc = procedure(const message: string);

const
  //
  c_logModeFlags_critical	= $0001;
  c_logModeFlags_normal		= $0002;
  c_logModeFlags_debug 		= $0004;
  c_logModeFlags_noOL 		= $0008;


{*
  Calls infoMessage() or does nothing if <STRONG>DEBUG</STRONG> symbol was not defined.
}
function assertLogMessage(const message: string; logToScreen: int = -1; logToFile: int = -1; logTimeMode: unaInfoMessage_logTimeModeEnum = unaLtm_default; logMemoryInfo: int = -1; logThreadId: int = -1): bool;
{*
  Displays the message on the screen, adds it to debug log file and/or passes it to the infoMessageProc.
  See setInfoMessageMode() for details.
}
function infoMessage(const message: string; logToScreen: int = -1; logToFile: int = -1; logTimeMode: unaInfoMessage_logTimeModeEnum = unaLtm_default; logMemoryInfo: int = -1; logThreadId: int = -1; flags: int = 0): bool;
{*
  Same as infoMessage() but also checks mode parameter. If (mode > infoLogMessageMode) does nothing.
}
function logMessage(const message: string = ''; flags: int = {$IFDEF DEBUG } c_logModeFlags_debug or {$ENDIF DEBUG } c_logModeFlags_normal; logToScreen: int = -1; logToFile: int = -1; logTimeMode: unaInfoMessage_logTimeModeEnum = unaLtm_default; logMemoryInfo: int = -1; logThreadId: int = -1): bool;

{*
  Specifies the name of debug log and infoMessageProc procedure to be used by the infoMessage() routine.
}
function setInfoMessageMode(const logName: wString = ''; proc: infoMessageProc = nil; logToScreen: int = -1; logToFile: int = -1; logTimeMode: unaInfoMessage_logTimeModeEnum = unaLtm_default; logMemoryInfo: int = -1; logThreadId: int = -1; useWideStrings: bool = false): wString;

{$IFDEF DEBUG}
{*
  Used to display the memory size currently allocated by application.
}
function debug_memAllocated(): unsigned;
{$ENDIF}

// colors
type
  //
  // -- color --
  //
  pRGB = ^tRGB;
  tRGB = packed record
    case bool of
      true: (
	     r: byte;
	     g: byte;
	     b: byte;
	    );
      false: (
	      asInt: int;
	     );
  end;

  //
  // -- color ops --
  //

  tunaColorOp = (unaco_invalid, unaco_wearOut);


{*
}
function color2str(color: int): string;
{*
}
function color2rgb(color: int): tRGB;
{*
}
function colorShift(color: int; op: tunaColorOp): int;

//	WIN API

// 	  -- REGISTRY --

{*
  Reads data from registry.
}
function getRegValue(const path: aString; const keyName: aString; var buf; var size: DWORD; rootKey: HKEY = HKEY_CURRENT_USER): long; overload;
{*
  Writes data to registry.
}
function setRegValue(const path: aString; const keyName: aString; const buf; size: DWORD; keyType: int; rootKey: HKEY = HKEY_CURRENT_USER): long; overload;
{*
  Reads integer value from registry.
}
function getRegValue(const path: aString; const keyName: aString = ''; defValue: int = 0; rootKey: HKEY = HKEY_CURRENT_USER): int; overload;
function getRegValue(const path: aString; const keyName: aString = ''; defValue: unsigned = 0; rootKey: HKEY = HKEY_CURRENT_USER): unsigned; overload;
{*
  Writes integer value into registry.
}
function setRegValue(const path: aString; const keyName: aString = ''; keyValue: int = 0; rootKey: HKEY = HKEY_CURRENT_USER): long; overload;
function setRegValue(const path: aString; const keyName: aString = ''; keyValue: unsigned = 0; rootKey: HKEY = HKEY_CURRENT_USER): long; overload;
{*
  Reads aString value from registry.
}
function getRegValue(const path: aString; const keyName: aString = ''; const defValue: aString = ''; rootKey: HKEY = HKEY_CURRENT_USER): aString; overload;
{*
  Writes string value into registry.
}
function setRegValue(const path: aString; const keyName: aString = ''; const keyValue: aString = ''; rootKey: HKEY = HKEY_CURRENT_USER): long; overload;

{*
  Enables or disables autorun of specified appication (current module will be used by default).
}
function enableAutorun(doEnable: bool = true; const appPath: wString = ''): bool;

// 	  -- MESSAGES --

{*
  	Processes messages waiting to be processed by application or window.

	@return number of messages being processed.
}
function processMessages(wnd: hWnd = 0): unsigned;

{$IFDEF FPC }

type
{$EXTERNALSYM tagPROCESSENTRY32W}
  tagPROCESSENTRY32W = record
    dwSize: DWORD;
    cntUsage: DWORD;
    th32ProcessID: DWORD;       // this process
    th32DefaultHeapID: DWORD;
    th32ModuleID: DWORD;        // associated exe
    cntThreads: DWORD;
    th32ParentProcessID: DWORD; // this process's parent process
    pcPriClassBase: Longint;    // Base priority of process's threads
    dwFlags: DWORD;
    szExeFile: array[0..MAX_PATH - 1] of WChar;  // Path
  end;
{$EXTERNALSYM PROCESSENTRY32W}
  PROCESSENTRY32W = tagPROCESSENTRY32W;
{$EXTERNALSYM PPROCESSENTRY32W}
  PPROCESSENTRY32W = ^tagPROCESSENTRY32W;
{$EXTERNALSYM LPPROCESSENTRY32W}
  LPPROCESSENTRY32W = ^tagPROCESSENTRY32W;
  TProcessEntry32W = tagPROCESSENTRY32W;

{$ENDIF FPC }

{*
	Runs an external application.

	@param moduleAndParams Module name along with paremeteres.
	@param waitForExit should the function wait till module terminates?
	@param showFlags how should application appear on screen
	@param redirectFromWOW64 under WOW64 will redirect from %windir%\SysWOW64 to %windir%\Sysnative. Usefull only for calling system 64-bit apps from 32-bit process.

	@return 0 if succeeded or GetLastError() otherwise.
}
function execApp(const moduleAndParams: wString = ''; waitForExit: bool = true; showFlags: WORD = SW_SHOW; redirectFromWOW64: bool = false): int; overload;
{*
	Runs an external application.

	@param module Module name (with optional full path).
	@param params Parameters (optional).
	@param waitForExit should the function wait till module terminates?
	@param showFlags how should application appear on screen
	@param redirectFromWOW64 under WOW64 will redirect from %windir%\SysWOW64 to %windir%\Sysnative. Usefull only for calling system 64-bit apps from 32-bit process.

	@return 0 if succeeded or GetLastError() otherwise.
}
function execApp(const module: wString; const params: wString = ''; waitForExit: bool = true; showFlags: WORD = SW_SHOW; redirectFromWOW64: bool = false): int; overload;
{*
}
function locateProcess(var procEntryW: PROCESSENTRY32W; const exeName: wString = ''): bool;

type
  pprocessEntryArrayW = ^processEntryArrayW;
  processEntryArrayW = array[byte] of PROCESSENTRY32W;

  pHandleArray = ^handleArray;
  handleArray = array[byte] of tHandle;

{*
}
function locateProcesses(var procEntriesW: pprocessEntryArrayW; const exeName: wString = ''): int;

{*
}
function windowsEnum(var wnds: pHandleArray): unsigned;
{*
}
function windowGetFirstChild(parent: hWnd): hWnd;
{*
}
function getProcessWindows(var wnds: pHandleArray; processId: unsigned = 0): unsigned;
{*
  returns processId of first process with same module name,
  or 0 if no such proccess was found.
}
function checkIfDuplicateProcess(doFlashWindow: bool = true): unsigned; overload;
{*
  Returns false if no mutex with given name was created by the time
  of this function execution.

  Creates mutex if it was not created before and returns its handle.

  If mutex already exists, returns true (mutex handle will be valid only when closeIfFound is false).
}
function checkIfDuplicateProcess(const mutexName: wString; var mutex: tHandle; closeIfFound: bool = true): bool; overload;
{*
}
function setPriority(value: int): int;
{*
}
function getPriority(): int;

{*
  Returns 0 if successfull.
}
function putIntoClipboard(const data: aString; window: hWnd = 0{current task}): int;

//	  -- MEMORY --

{*
  Returns allocated memory size.
}
function ams(): int;

{*
	Fills memory block with specified word value.

	@param count count of words (not bytes)
}
procedure mfill16(mem: pointer; count: unsigned; value: uint16 = 0);

{*
  Allocates block of memory.

  @param size size of block to allocate.
  @param doFill specifies wether to fill allocated memory block with some value (default is false).
  @param fill specifies the value to fill the allocated block with.

  @return pointer to allocated memory block.
}
function malloc(size: unsigned; doFill: bool = false; fill: byte = 0): pointer; overload;
{*
  Allocates block of memory.

  @param size size of block to allocate.
  @param data pointer to a data buffer to be copied into allocated block (must contain at least size bytes).

  @return pointer to allocated memory block.
}
function malloc(size: unsigned; data: pointer): pointer; overload;

{*
  Compares two memory blocks.

  @param p1 pointer to first block.
  @param p2 pointer to second block.

  @return true if at least size bytes are equal.
}
function mcompare(p1, p2: pointer; size: unsigned): bool;

{*
	Reallocates block of memory.
	Has same functionality as ReallocMem() routine.

	@return the resulting pointer.
}
procedure mrealloc(var data; newSize: unsigned = 0);

{*
  Scans memory for a byte value.
  Count is number of bytes in buf array.
}
function mscanb(buf: pointer; count: unsigned; value: uint8): pointer;
{*
  Scans memory for a word value.
  Count is a number of words in buf array.
}
function mscanw(buf: pointer; count: unsigned; value: uint16): pointer;
{*
  Scans memory for a double word value.
  Count is a number of double words in buf array.
}
function mscand(buf: pointer; count: unsigned; value: uint32): pointer;
{*
  Scans memory for a quad word value.
  Count is a number of quad words in buf array.
}
function mscanq(buf: pointer; count: unsigned; const value: int64): pointer;
{*
  Scans memory for array of bytes, pointed by value.
  bufSize is number of bytes in buf array.
  valueLen is number of bytes in value array.
}
function mscanbuf(buf: pointer; bufSize: unsigned; value: pointer; valueLen: unsigned): pointer;
{*
  Swaps int16/uint16 values in a buffer. Len is in bytes and should be even.
}
procedure mswapbuf16(buf: pointer; len: int);

{*
  Disposes an object.
  <P />Assigns nil value to the object reference.
}
procedure freeAndNil(var objRef);{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }

{$IFDEF CHECK_MEMORY_LEAKS }

const
  // -- should be enough, increase if necessary --
  maxLeakEntries 	= $20000;
  maxCallStackDepth	= 20;

{*
  passing larger stack size may result in AV for small stacks,
  but increases the possible depth of call stack entry points
}
procedure mleaks_start(maxStackSize: unsigned = 250{fits for most cases});
{*
}
procedure mleaks_stop(produceReport: bool = true);

{$ENDIF }	// CHECK_MEMORY_LEAKS

//	  -- EVENTS --

{*
	Waits specified amount of time for event to be sent in signaled state.

	@return true if event was sent to signaled state.
}
function waitForObject(handle: tHandle; timeout: unsigned = 1): bool;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }


type
  unaAcquireType = int32;	///


//        -- QUICK MT-SAFE ACQUISITION --
{*
	Acquires an object (interger counter).

	This acquire always success, simply marking an object as "busy".
	Don't forget to call release32() when object is no longer needed to be locked.

	@param a Object to acquire.
}
procedure acquire32(var a: unaAcquireType); overload;       (* {$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE } *)

{*
	Acquires an object (interger counter) and returns true if counter was
	equial to 0 exactly at this acquisition attempt.

	If acquisition failed, releases the object, so there is no need to call release32() if this function returns false.

	@param a Object to acquire.
	@param timeout Time in ms to spend trying to acquire. 0 means give up without waiting.

	@return True if object was acquired exactly at this acquisition attempt.
}
function acquire32(var a: unaAcquireType; timeout: int): bool; overload; (* {$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE } *)
{*
	Releases object, acquired with acquireObj().
	If exclusive parameter was false, object must always be released.

	Release always succeeds. Return value simply indicates if object counter
	reached 0 after release (or not), so it would be possible to maintain a,
	for example, number of acquired objects.

	@param acquire Object to release.

	@return True if object ref count has reached 0.
}
function release32(var a: unaAcquireType): bool;(* {$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE } *)


//	  -- HRPC/WINDOWS TIMER --

var
  hrpc_Freq: int64 = 0;		// ticks per second
  hrpc_FreqFail: bool = false; 	// true if we cannot use HRPP
  hrpc_FreqMs: int64 = 0;	// ticks per millisecond

{*
  "Marks" current time. Uses high-resolution performance counter (HPRC) if possible or GetTickCount() otherwise.
}
function timeMark(): int64;
{*
  Returns number of milliseconds passed between given mark and current time.
  Uses high-resolution performance counter (HPRC) if available, or GetTickCount() otherwise.
}
function timeElapsed32(mark: int64): unsigned;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
{*
  Returns number of milliseconds passed between given mark and current time.
  Uses high-resolution performance counter (HPRC) if available, or GetTickCount() otherwise.
}
function timeElapsed64(mark: int64): int64;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
{*
  Returns number of internal ticks passed between given mark and current time.
  Uses high-resolution performance counter (HPRC) if available.
}
function timeElapsed64ticks(mark: int64): int64;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }

//
function sanityCheck(var mark: int64; maxSlice: unsigned = 300; sleepSlice: unsigned = 20; careMessages: bool = true): bool;
function sanityCheck64(var mark: int64; maxSlice: int64 = 300000; sleepSlice: unsigned = 20; careMessages: bool = false): bool;

//	  -- ERROR --

{*
  Returns Windows system error message for given error code.
  <P />If errorCode parameter is 0 (default) it will be replaced with Window.GetLastError() value.
}
function getSysErrorText(errorCode: DWORD = 0; avoidGetCall: bool = false): wString;

// 	OTHER

// -- --
{*
  Returns one of the choices depending on value of boolean selector.
}
function choice(value: bool; true_choice: char = ' '; false_choice: char = ' '): char; overload;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }

{$IFDEF __BEFORE_DC__ }

{*
  Returns one of the choices depending on value of boolean selector.
}
function choice(value: bool; true_choice: wChar = ' '; false_choice: wChar = ' '): wChar; overload;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
{$ELSE }
{*
  Returns one of the choices depending on value of boolean selector.
}
function choice(value: bool; true_choice: aChar = ' '; false_choice: aChar = ' '): aChar; overload;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }

{$ENDIF __BEFORE_DC__ }

{*
  Returns one of the choices depending on value of boolean selector.
}
function choice(value: bool; true_choice: int = 1; false_choice: int = 0): int; overload;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
{*
  Returns one of the choices depending on value of boolean selector.
}
function choice(value: bool; true_choice: unsigned = 1; false_choice: unsigned = 0): unsigned; overload;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }

{$IFDEF __BEFORE_D6__ }
  // Delphi 4 and 5 gone ambiguous with wide/ansi strings
  // So we lost some functionality but avoid ambiguousness
{$ELSE }
{*
  Returns one of the choices depending on value of boolean selector.
}
function choice(value: bool; const true_choice: string; const false_choice: string = ''): string; overload;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
{$ENDIF __BEFORE_D6__ }

{$IFDEF __BEFORE_DC__ }
function choice(value: bool; const true_choice: wString; const false_choice: wString = ''): wString; overload;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
{$ELSE }
function choice(value: bool; const true_choice: aString; const false_choice: aString = ''): aString; overload;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
{$ENDIF __BEFORE_DC__ }

{*
  Returns one of the choices depending on value of boolean selector.
}
function choice(value: bool; true_choice: boolean = true; false_choice: boolean = false): bool; overload;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
{*
  Returns one of the choices depending on value of boolean selector.
}
function choice(value: bool; true_choice: tObject = nil; false_choice: tObject = nil): tObject; overload;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
{*
  Returns one of the choices depending on value of boolean selector.
}
function choice(value: bool; true_choice: pointer = nil; false_choice: pointer = nil): pointer; overload;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }

{*
  Returns one of the choices depending on value of boolean selector.
}
function choiceD(value: bool; const true_choice: double = 0; false_choice: double = 0): double;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
{*
  Returns one of the choices depending on value of boolean selector.
}
function choiceE(value: bool; const true_choice: extended = 0; false_choice: extended = 0): extended;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }

{*
  Returns greatest common divider.
  <P />For example, if a=11025 and b=1000 the result will be 25.
}
function gcd(a, b: unsigned): unsigned;


type
  //
  // -- security attribute --
  //
  PSECURITY_ATTRIBUTES = ^SECURITY_ATTRIBUTES;
{$IFDEF FPC }
{$ELSE }
  SECURITY_ATTRIBUTES = packed record
    //
    nLength: DWORD;
    lpSecurityDescriptor: PSecurityDescriptor;
    bInheritHandle: bool;
  end;

{$ENDIF FPC }

// --  --
function getNullDacl(): PSECURITY_ATTRIBUTES;


var
{$IFNDEF NO_ANSI_SUPPORT }
  /// Do host OS supports unicode strings?
  /// true if running on NT or later (wide API seems to be present)
  g_wideApiSupported: bool;
{$ENDIF NO_ANSI_SUPPORT }

  /// OS version information
  g_OSVersion: OSVERSIONINFOW;

  /// Are we running unser WOW64?
  g_isWOW64: bool;


implementation


uses
  unaPlacebo
{$IFDEF UNA_PROFILE }
  , unaProfile
{$ENDIF UNA_PROFILE }
  ;

{$IFDEF UNA_PROFILE }
var
  profId_unaUtils_base64encode: unsigned;
  profId_unaUtils_base64decode: unsigned;
{$ENDIF UNA_PROFILE }

var
{$IFDEF CONSOLE_IO }
  // for console applications we will try to open console I/O handlers
  g_CONIN: tHandle = 0;
  g_CONOUT: tHandle = 0;
{$ENDIF CONSOLE_IO }
  //
  g_infoLogTimeMode: unaInfoMessage_logTimeModeEnum = {$IFDEF DEBUG}unaLtm_dateTimeDelta{$ELSE}unaLtm_none{$ENDIF};
  g_infoLogToFile: bool = true;
  g_infoLogToFileName: bool = true;
  g_infoLogFileNameW: wString = '';
  g_infoLogFileHandle: tHandle = INVALID_HANDLE_VALUE;
  //
  g_infoLogToScreen: int   = {$IFDEF CONSOLE } 1 {$ELSE } 0 {$ENDIF };	// set to 2 to suppress infoMessage() of adding #13#10 at the end of aString
  g_infoLogMemoryInfo: bool = {$IFDEF DEBUG   } true {$ELSE } false {$ENDIF };
  g_infoLogThreadId: bool   = {$IFDEF DEBUG   } true {$ELSE } false {$ENDIF };
  //
  g_infoLogProcedure: infoMessageProc = nil;
  //
  g_infoLogMessageFlags: int = {$IFDEF DEBUG } c_logModeFlags_debug or {$ENDIF } c_logModeFlags_normal or c_logModeFlags_critical;
  //
  g_infoLogUseSystemTime: bool = true;		// use system(UTC) or local time for logging
  g_infoLogUseWideStrings: bool = false;	// use wide string when writting into log file

  //
  g_infoLogTimeMark: int64;
  g_infoLogLastDate: SYSTEMTIME;

  {$IFDEF VC25_OVERLAPPED }
  g_logOL: array[byte] of OVERLAPPED;
  g_logOLOffs: int;
  g_logOLEvents: array[byte] of tHandle;
  g_logOLBufs: array[byte] of pointer;
  g_logOLBufsSz: array[byte] of int;
  g_logOLCount: unsigned;
  {$ENDIF VC25_OVERLAPPED }

  g_unaUtilsFinalized: bool = false;


// --  --
function min(A, B: int): int;
begin
  if (A > B) then
    result := B
  else
    result := A;
end;

{$IFNDEF CPU64 }

// --  --
function min(A, B: int64): int64;
begin
  if (A > B) then
    result := B
  else
    result := A;
end;

// --  --
function max(A, B: int64): int64;
begin
  if (A < B) then
    result := B
  else
    result := A;
end;

{$ENDIF CPU64 }

// --  --
function min(A, B: unsigned): unsigned;
begin
  if (A > B) then
    result := B
  else
    result := A;
end;

// --  --
function max(A, B: int): int;
begin
  if (A < B) then
    result := B
  else
    result := A;
end;

// --  --
function max(A, B: unsigned): unsigned;
begin
  if (A < B) then
    result := B
  else
    result := A;
end;

// --  --
function max(A, B: double): double;
begin
  if (A < B) then
    result := B
  else
    result := A;
end;

{$IFDEF __SYSUTILS_H_ }
{$ELSE }

// --  --
procedure abort();
var
  n: int;
begin
  n := 0;
  n := 1 div n;
  if (0 < n) then
    ; // compiler is broken :)
end;

{$ENDIF __SYSUTILS_H_ }

// --  --
function base64encode(data: pointer; size: unsigned): aString;
const
  Base64: aString = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
var
  L: unsigned;
  P: aString;
  j: unsigned;
  i: unsigned;
  d: pArray;
begin
{$IFDEF UNA_PROFILE }
  profileMarkEnter(profId_unaUtils_base64encode);
{$ENDIF UNA_PROFILE }
  result := '';
  i := 0;
  //
  d := data;
  if (d <> nil) then begin
    //
    while (i < size) do begin
      //
      P := '';
      L := (d[i] shl 16);
      inc(i);
      if (i < size) then begin
	L := L + unsigned(d[i] shl 8);
	inc(i);
	if (i < size) then
	  inc(L, d[i])
	else
	  P := '=';
      end
      else
	P := '==';
      //
      for j := 1 to 4 - length(P) do begin
	//
	result := result + Base64[(L and $FC0000) shr 18 + 1];
	L := L shl 6;
      end;
      //
      if (P <> '') then begin
	result := result + P;
	break;
      end;
      //
      inc(i);
    end;
  end;
{$IFDEF UNA_PROFILE }
  profileMarkLeave(profId_unaUtils_base64encode);
{$ENDIF UNA_PROFILE }
end;

// -- --
function base64encode(const data: aString): aString;
begin
  if ('' <> data) then
    result := base64encode(@data[1], length(data))
  else
    result := '';
end;

// -- --
function char2int(const data: aString; var ofs: unsigned): unsigned;
var
  c: aChar;
begin
  if (unsigned(length(data)) >= ofs) then begin
    //
    c := data[ofs];

    case (c) of

      'A'..'Z': result := ord(c) - ord('A');
      'a'..'z': result := ord(c) - ord('a') + 26;
      '0'..'9': result := ord(c) - ord('0') + 52;
      '+'     : result := 62;
      '/'     : result := 63;
      else      result := 64;

    end;
    inc(ofs);
  end
  else
    result := 65;
end;

// --  --
function base64decode(data: pointer; len: unsigned): aString;
var
  dataStr: aString;
begin
  if ((0 < len) and (nil <> data)) then begin
    //
    setLength(dataStr, len);
    move(data^, dataStr[1], len);
    result := base64decode(dataStr);
  end
  else
    result := '';
end;

// --  --
function base64decode(const data: aString): aString;
var
  Z: unsigned;
  L: unsigned;
  i: unsigned;
  j: int;
  c: int;
  V: byte;
  D: byte;
begin
{$IFDEF UNA_PROFILE}
  profileMarkEnter(profId_unaUtils_base64decode);
{$ENDIF}
  //
  result := '';
  i := 1;
  Z := length(data);
  while (i <= Z) do begin
    //
    V := 0;
    L := 0;
    c := 18;
    repeat
      //
      D := char2int(data, i);
      case (D) of

	64:
	  continue;	// invalid char (or '=')

	65:
	  break;	// end of data

	else begin
	  //
	  L := L + unsigned(D shl c);
	  c := c - 6;
	  inc(V);
	end;
      end;
      //
    until (3 < V);
    //
    for j := 1 to V - 1 do begin
      //
      result := result + aChar((L and $FF0000) shr 16);
      L := L shl 8;
    end;
    //
  end;
  //
{$IFDEF UNA_PROFILE}
  profileMarkLeave(profId_unaUtils_base64decode);
{$ENDIF}
end;

// -- --
function base64decode(const data: aString; out buf: pointer): unsigned;
var
  str: aString;
begin
  str := base64decode(data);
  result := length(str);
  if (result > 0) then begin
    //
    buf := malloc(result);
    move(str[1], buf^, result);
  end
  else
    buf := nil;
end;

// --  --
function base65encode(data: pointer; len: unsigned): aString;
var
  sz: int;
begin
  if (nil <> data) then begin
    //
    sz := (len shl 3);
    if (0 <> sz mod 5) then
      sz := sz div 5 + 1
    else
      sz := sz div 5;
    //
    setLength(result, sz);
    asm
	mov	ecx, len
	or	ecx,ecx
	jz	@done

	push	esi
	push	edi
	push	ebx

	mov	esi, data
	mov	edi, result
	{$IFDEF FPC }
	mov	edi, [{$IFDEF CPU64 }rdi{$ELSE }edi{$ENDIF CPU64 }]
        {$ELSE }
	mov	edi, [edi]
        {$ENDIF FPC }

	mov	ebx, ecx	// EBX = sz
	mov	dl, 5		// magic value :)
	sub	dh, dh		// DH = 0 (5 bit value)
	mov	cl, dh		// CL = 0 (bits left from prev. byte)

  @nextByte:
	lodsb

	or	cl, cl
	jz	@noBits		// no bits left

	// CL bits left in AH from prev. conversion
	mov	dh, al
	shl	dh, cl
	or	dh, ah
	and	dh, $01F
	// store dh
	mov	ch, dh
	add	ch, 'B'
	cmp	dh, 25
	jb	@doStore1

	mov	ch, dh
	sub	ch, 25
	add	ch, '0'

    @doStore1:
        {$IFDEF FPC }
	mov	[{$IFDEF CPU64 }rdi{$ELSE }edi{$ENDIF CPU64 }], ch
	{$ELSE }
	mov	[edi], ch
	{$ENDIF FPC }
	inc	edi

	mov	ch, dl
	sub	ch, cl
	mov	cl, ch

  @noBits:
	// shift the value
	mov	ch, 8
	mov	dh, al
	mov	ah, al

    @nextShift:
	cmp	cl, 3
	ja	@notEnough

	shr	dh, cl
	shr	ah, cl
	and	dh, $01F
	// store dh
	mov	al, dh
	add	al, 'B'
	cmp	dh, 25
	jb	@doStore2

	mov	al, dh
	sub	al, 25
	add	al, '0'

    @doStore2:
	stosb

    @notEnough:
	sub	ch, cl
	cmp	cl, 3
	ja	@notEnough2

	add	cl, dl
	mov	cl, dl
	sub	ch, cl
    @notEnough2:

	shr	ah, cl
	//
	// -- not needed, since 5 never fit twice in 8
	//cmp	ch, cl
	//jae	@nextShift

	mov	cl, ch
	//
	dec	ebx
	jnz	@nextByte

	or	cl, cl
	jz	@nothingLeft

	// store ah
	mov	al, ah
	add	al, 'B'
	cmp	ah, 25
	jb	@doStore3

	mov	al, ah
	sub	al, 25
	add	al, '0'

    @doStore3:
	stosb

  @nothingLeft:
	pop	ebx
	pop	edi
	pop	esi
  @done:
    end;
  end
  else
    result := '';
end;

// --  --
function base65encode(const data: aString): aString;
begin
  if ('' <> data) then
    result := base65encode(@data[1], length(data))
  else
    result := '';
end;

// --  --
function base65decode(const data: aString): aString;
begin
  if ('' <> data) then
    result := base65decode(@data[1], length(data))
  else
    result := '';
end;

// --  --
function base65decode(data: pointer; len: unsigned): aString;
var
  sz: int;
begin
  if (nil <> data) then begin
    //
    sz := len * 5 shr 3;
    setLength(result, sz);
    asm
	mov	ecx, len
	or	ecx, ecx
	jz	@done

	push	esi
	push	edi
	push	ebx

	mov	esi, data
	mov	edi, result
        {$IFDEF FPC }
	mov	edi, [{$IFDEF CPU64 }rdi{$ELSE }edi{$ENDIF CPU64 }]
	{$ELSE }
	mov	edi, [edi]
        {$ENDIF FPC }

	mov	ebx, ecx
	sub	edx, edx
	sub	ecx, ecx

  @nextValue:
	//
	sub	eax, eax
	lodsb
	//
	cmp	al, 'B'
	jae	@subChar

	cmp	al, '0'
	jb	@skip

	sub	al, '0'
	add	al, 25
	cmp	al, 32
	jae	@skip

	jmp	@gotValue

    @subChar:
	sub	al, 'B'
	cmp	al, 25
	jae	@skip

	// -- got proper 5 bit value --
    @gotValue:
	add	ch, 5		// got new 5 bits
	shl 	eax, cl		// shift to proper position
	or	edx, eax

    @storeByte:
	cmp	ch, 8
	jb	@notFullByteYet

	mov	al, dl
	stosb

	shr	edx, 8
	sub	ch, 8
	jmp	@storeByte

    @notFullByteYet:
	mov	cl, ch

    @skip:
	dec	ebx
	jnz	@nextValue

        {$IFDEF CPU64 }
	mov	rdx, result
	mov	rdx, [rdx]
	{$ELSE }
	mov	edx, result
	mov	edx, [edx]
        {$ENDIF CPU64 }

	xchg	edx, edi
	sub	edx, edi
        {$IFDEF CPU64 }
	mov	sz, rdx
	{$ELSE }
	mov	sz, edx
        {$ENDIF CPU64 }

	pop	ebx
	pop	edi
	pop	esi
  @done:
    end;
    //
    setLength(result, sz);
  end
  else
    result := '';
end;

// --  --
function baseXencode(const data, key: aString; ver: int): aString;
var
  x: byte;
  lenD: int;
  lenK: int;
  i: int;
  j: int;
begin
  result := '';
  lenD := length(data);
  //
  if (0 < lenD) then begin
    //
    lenK := length(key);
    x := 0;
    j := 1;
    //
    case (ver) of

      100, 101: begin
	//
	setLength(result, lenD);
	//
	for i := 1 to lenD do begin
	  x := x xor byte(data[i]);
	  //
	  if (j > lenK) then
	    j := 1;
	  //
	  if (j <= lenK) then
	    x := x xor byte(key[j]);
	  inc(j);
	  //
	  result[i] := aChar(x);
	end;
	//
	if (100 = ver) then
	  result := base64encode(result);
      end;

      else
	result := data;	// this encryption version is not supported
    end;
  end;
end;

// --  --
procedure swap8array(p1, p2: pArray);
var
  b: uint8;
begin
  b := p2[0];
  p2[0] := p1[0];
  p1[0] := b;
end;

// --  --
function baseXdecode(const data, key: aString; ver: int): aString;
var
  x: byte;
  lenD: int;
  lenK: int;
  i: int;
  j: int;
begin
  result := '';
  lenD := length(data);
  //
  if (0 < lenD) then begin
    //
    lenK := length(key);
    x := 0;
    j := 1;
    //
    case (ver) of

      100, 101: begin
	//
	if (100 = ver) then
	  result := base64decode(data)
	else
	  result := data;
	//
	lenD := length(result);
	//
	for i := 1 to lenD do begin
	  x := x xor byte(result[i]);
	  //
	  if (j > lenK) then
	    j := 1;
	  //
	  if (j <= lenK) then
	    x := x xor byte(key[j]);
	  inc(j);
	  //
	  swap8array(pArray(@result[i]), pArray(@x));
	end;
      end;

      else
	result := data;	// this encryption version is not supported
    end;
  end;
end;

// --
// CRC32() routine, based on Hagen Reddmann code, some modifications by Lake
// --
function CRC32(crc: longWord; data: pointer; dataSize: longWord): longWord; assembler; overload;
{
	IN:	EAX = CRC
		EDX = Data
		ECX = DataSize

	OUT:    EAX = result
}
asm
	or	edx, edx
	jz	@exit

	jecxz	@exit

	push	ebx
	push	edi

	xor	ebx, ebx
	lea	edi, @crc32table

  @loop:
	mov	bl, al
	shr	eax, 8
	//
        {$IFDEF FPC }
	xor	bl, [{$IFDEF CPU64 }rdx{$ELSE }edx{$ENDIF CPU64 }]
	{$ELSE }
	xor	bl, [edx]
        {$ENDIF FPC }
	inc	edx
	//
        {$IFDEF FPC }
	xor	eax, [{$IFDEF CPU64 }rdi + rbx * 4{$ELSE }edi + ebx * 4{$ENDIF CPU64 }]
	{$ELSE }
	xor	eax, [edi + ebx * 4]
        {$ENDIF FPC }
	loop	@loop

	pop	edi
	pop	ebx

  @exit:
	ret

	dd	0, 0 // align

  @crc32table:
	// 00..0F
	DD 0000000AAh, 077073096h, 0EE0E612Ch, 0990951BAh
	DD 0076DC419h, 0706AF48Fh, 0E963A535h, 09E6495A3h
	DD 00EDB8832h, 079DCB8A4h, 0E0D5E91Eh, 097D2D988h
	DD 009B64C2Bh, 07EB17CBDh, 0E7B82D07h, 090BF1D91h
	// 10..1F
	DD 01DB71064h, 06AB020F2h, 0F3B97148h, 084BE41DEh
	DD 01ADAD47Dh, 06DDDE4EBh, 0F4D4B551h, 083D385C7h
	DD 0136C9856h, 0646BA8C0h, 0FD62F97Ah, 08A65C9ECh
	DD 014015C4Fh, 063066CD9h, 0FA0F3D63h, 08D080DF5h
	// 20..2F
	DD 03B6E20C8h, 04C69105Eh, 0D56041E4h, 0A2677172h
	DD 03C03E4D1h, 04B04D447h, 0D20D85FDh, 0A50AB56Bh
	DD 035B5A8FAh, 042B2986Ch, 0DBBBC9D6h, 0ACBCF940h
	DD 032D86CE3h, 045DF5C75h, 0DCD60DCFh, 0ABD13D59h
	// 30..3F
	DD 026D930ACh, 051DE003Ah, 0C8D75180h, 0BFD06116h
	DD 021B4F4B5h, 056B3C423h, 0CFBA9599h, 0B8BDA50Fh
	DD 02802B89Eh, 05F058808h, 0C60CD9B2h, 0B10BE924h
	DD 02F6F7C87h, 058684C11h, 0C1611DABh, 0B6662D3Dh
	// 40..4F
	DD 076DC4190h, 001DB7106h, 098D220BCh, 0EFD5102Ah
	DD 071B18589h, 006B6B51Fh, 09FBFE4A5h, 0E8B8D433h
	DD 07807C9A2h, 00F00F934h, 09609A88Eh, 0E10E9818h
	DD 07F6A0DBBh, 0086D3D2Dh, 091646C97h, 0E6635C01h
	// 50..5F
	DD 06B6B51F4h, 01C6C6162h, 0856530D8h, 0F262004Eh
	DD 06C0695EDh, 01B01A57Bh, 08208F4C1h, 0F50FC457h
	DD 065B0D9C6h, 012B7E950h, 08BBEB8EAh, 0FCB9887Ch
	DD 062DD1DDFh, 015DA2D49h, 08CD37CF3h, 0FBD44C65h
	// 60..6F
	DD 04DB26158h, 03AB551CEh, 0A3BC0074h, 0D4BB30E2h
	DD 04ADFA541h, 03DD895D7h, 0A4D1C46Dh, 0D3D6F4FBh
	DD 04369E96Ah, 0346ED9FCh, 0AD678846h, 0DA60B8D0h
	DD 044042D73h, 033031DE5h, 0AA0A4C5Fh, 0DD0D7CC9h
	// 70..7F
	DD 05005713Ch, 0270241AAh, 0BE0B1010h, 0C90C2086h
	DD 05768B525h, 0206F85B3h, 0B966D409h, 0CE61E49Fh
	DD 05EDEF90Eh, 029D9C998h, 0B0D09822h, 0C7D7A8B4h
	DD 059B33D17h, 02EB40D81h, 0B7BD5C3Bh, 0C0BA6CADh
	// 80..8F
	DD 0EDB88320h, 09ABFB3B6h, 003B6E20Ch, 074B1D29Ah
	DD 0EAD54739h, 09DD277AFh, 004DB2615h, 073DC1683h
	DD 0E3630B12h, 094643B84h, 00D6D6A3Eh, 07A6A5AA8h
	DD 0E40ECF0Bh, 09309FF9Dh, 00A00AE27h, 07D079EB1h
	// 90..9F
	DD 0F00F9344h, 08708A3D2h, 01E01F268h, 06906C2FEh
	DD 0F762575Dh, 0806567CBh, 0196C3671h, 06E6B06E7h
	DD 0FED41B76h, 089D32BE0h, 010DA7A5Ah, 067DD4ACCh
	DD 0F9B9DF6Fh, 08EBEEFF9h, 017B7BE43h, 060B08ED5h
	// A0..AF
	DD 0D6D6A3E8h, 0A1D1937Eh, 038D8C2C4h, 04FDFF252h
	DD 0D1BB67F1h, 0A6BC5767h, 03FB506DDh, 048B2364Bh
	DD 0D80D2BDAh, 0AF0A1B4Ch, 036034AF6h, 041047A60h
	DD 0DF60EFC3h, 0A867DF55h, 0316E8EEFh, 04669BE79h
	// B0..BF
	DD 0CB61B38Ch, 0BC66831Ah, 0256FD2A0h, 05268E236h
	DD 0CC0C7795h, 0BB0B4703h, 0220216B9h, 05505262Fh
	DD 0C5BA3BBEh, 0B2BD0B28h, 02BB45A92h, 05CB36A04h
	DD 0C2D7FFA7h, 0B5D0CF31h, 02CD99E8Bh, 05BDEAE1Dh
	// C0..CF
	DD 09B64C2B0h, 0EC63F226h, 0756AA39Ch, 0026D930Ah
	DD 09C0906A9h, 0EB0E363Fh, 072076785h, 005005713h
	DD 095BF4A82h, 0E2B87A14h, 07BB12BAEh, 00CB61B38h
	DD 092D28E9Bh, 0E5D5BE0Dh, 07CDCEFB7h, 00BDBDF21h
	// D0..DF
	DD 086D3D2D4h, 0F1D4E242h, 068DDB3F8h, 01FDA836Eh
	DD 081BE16CDh, 0F6B9265Bh, 06FB077E1h, 018B74777h
	DD 088085AE6h, 0FF0F6A70h, 066063BCAh, 011010B5Ch
	DD 08F659EFFh, 0F862AE69h, 0616BFFD3h, 0166CCF45h
	// E0..EF
	DD 0A00AE278h, 0D70DD2EEh, 04E048354h, 03903B3C2h
	DD 0A7672661h, 0D06016F7h, 04969474Dh, 03E6E77DBh
	DD 0AED16A4Ah, 0D9D65ADCh, 040DF0B66h, 037D83BF0h
	DD 0A9BCAE53h, 0DEBB9EC5h, 047B2CF7Fh, 030B5FFE9h
	// F0..FF
	DD 0BDBDF21Ch, 0CABAC28Ah, 053B39330h, 024B4A3A6h
	DD 0BAD03605h, 0CDD70693h, 054DE5729h, 023D967BFh
	DD 0B3667A2Eh, 0C4614AB8h, 05D681B02h, 02A6F2B94h
	DD 0B40BBE37h, 0C30C8EA1h, 05A05DF1Bh, 02D02EF8Dh
	//
end;

// --  --
function crc32(data: pointer; len: unsigned; crc: uint32 = $FFFFFFFF): uint32; 
begin
  result := crc32(crc, data, len);
end;

// --  --
function crc32(const data: aString; crc: uint32 = $FFFFFFFF): uint32;
begin
  if ('' <> data) then
    result := crc32(@data[1], length(data), crc)
  else
    result := crc32(nil, 0, crc);
end;

// --  --
function crc16(data: pointer; len: unsigned): uint16;
var
  crc: unsigned;
begin
  crc := crc32(data, len);
  //
  result := (crc shr 16) xor (crc and $FFFF);
end;

// --  --
function crc8(data: pointer; len: unsigned): uint8;
var
  crc: unsigned;
    i: unsigned;
begin
  crc := crc32(data, len);
  //
  result := 0;
  for i := 1 to 4 do begin
    //
    result := result xor byte(crc and $FF);
    crc := crc shr 8;
  end;
end;

// --  --
function crc4(data: pointer; len: unsigned): uint8; 
begin
  result := crc8(data, len);
  result := (result and $0F) xor ((result shr 4) and $0F);
end;



// -- UTF8/UTF16/Unicode functions --

// --  --
function cp2UTF8(cp: uint32): aString;
begin
  if (cp < $00000080) then begin
    // 0000 0000-0000 007F
    result := aChar(cp)
  end
  else
    if (cp < $00000800) then begin
      // 0000 0080-0000 07FF
      result := aChar($C0 or ((cp shr 6) and $FF)) +
		aChar($80 or  (cp and $3F));
    end
    else
      if (cp < $00010000) then begin
	// 0000 0800-0000 FFFF
	result := aChar($E0 or ((cp shr 12) and $FF)) +
		  aChar($80 or ((cp shr 6)  and $3F)) +
		  aChar($80 or  (cp and $3F));
      end
      else
	if (cp < $00200000) then begin
	  // 0001 0000-001F FFFF
	  result := aChar($F0 or ((cp shr 18) and $FF)) +
		    aChar($80 or ((cp shr 12) and $3F)) +
		    aChar($80 or ((cp shr 6)  and $3F)) +
		    aChar($80 or  (cp and $3F));
	end
	else
	  if (cp < $04000000) then begin
	    // 0020 0000-03FF FFFF
	    result := aChar($F8 or ((cp shr 24) and $FF)) +
		      aChar($80 or ((cp shr 18) and $3F)) +
		      aChar($80 or ((cp shr 12) and $3F)) +
		      aChar($80 or ((cp shr 6)  and $3F)) +
		      aChar($80 or  (cp and $3F));
	  end
	  else
	    if (cp < $80000000) then begin
	      // 0400 0000-7FFF FFFF
	      result := aChar($FC or ((cp shr 30) and $FF)) +
			aChar($80 or ((cp shr 24) and $3F)) +
			aChar($80 or ((cp shr 18) and $3F)) +
			aChar($80 or ((cp shr 12) and $3F)) +
			aChar($80 or ((cp shr 6)  and $3F)) +
			aChar($80 or  (cp and $3F));
	    end
	    else
	      result := '';
  //
end;

// --  --
function highSurrogate(cp: uint32): uint16;
begin
  result := unicodeHighSurrogateStart or (((cp shr 16) and ((1 shl 5) - 1) - 1) shl 6) or ((cp and $FFFF) shr 10);
end;

// --  --
function isHighSurrogate(w: uint16): bool;
begin
  result := (unicodeHighSurrogateStart <= w) and (unicodeHighSurrogateEnd >= w);
end;

// --  --
function isLowSurrogate(w: uint16): bool;
begin
  result := (unicodeLowSurrogateStart <= w) and (unicodeLowSurrogateEnd >= w);
end;

// --  --
function lowSurrogate(cp: uint32): uint16;
begin
  result := unicodeLowSurrogateStart or ((cp and $FFFF) and ((1 shl 10) - 1));
end;

// --  --
function surrogate2cp(highSurrogate, lowSurrogate: uint16): uint32;
begin
  result := highSurrogate shl 10 + lowSurrogate + $10000 - (unicodeHighSurrogateStart shl 10) - unicodeLowSurrogateStart;
end;

function UTF162UTF8(const w: wString): aString;
var
  i: int;
  cp: uint32;
begin
  result := '';
  //
  i := 1;
  while (i <= length(w)) do begin
    //
    cp := 0;
    if (not isHighSurrogate(ord(w[i]))) then
      cp := ord(w[i])
    else begin
      //
      {$IFDEF LOG_UNAUTILS_ERRORS }
      if (length(w) < i + 1) then
	logMessage('unaUtils.UTF162UTF8() - not enough chars for UTF-16 value');
      {$ENDIF LOG_UNAUTILS_ERRORS }
      //
      if (length(w) >= i + 1) then begin
	//
	cp := surrogate2cp(ord(w[i]), ord(w[i + 1]));
	inc(i);
      end;
    end;
    //
    result := result + cp2UTF8(cp);
    //
    inc(i);
  end;
end;

// --  --
function UTF82UTF16(const s: aString): wString;
var
  i: int;
  cp: uint32;
  len: int;
  b: pArray;
  rpos: int;
  rlen: int;
begin
  len := length(s);
  rlen := len;
  setLength(result, rlen);
  //
  if (0 < len) then begin
    //
    i := 0;
    rpos := 1;
    //
    b := pArray(@s[1]);
    while (i < len) do begin
      //
      cp := 0;
      if (b[i] < $80) then begin
        //
	// 7 bits packed in 1 byte: 0xxx.xxxx
	cp := b[i];
      end
      else begin
        //
	if (b[i] < $E0) then begin
          //
	  // 11 bits packed in 2 bytes: 110x.xxxx 10xx.xxxx
          //
	  {$IFDEF LOG_UNAUTILS_ERRORS }
	  if (len <= i + 1) then
	    logMessage('unaUtils.UTF82UTF16() - not enough chars for UTF-8 value [1]');
	  {$ENDIF LOG_UNAUTILS_ERRORS }
	  //
	  if (len > i + 1) then
	    cp :=  (b[i + 0] and $1F) shl 6 or
		    b[i + 1] and $3F;
	  //
	  inc(i);
	  dec(rlen);
	end
	else begin
          //
	  if (b[i] < $F0) then begin
            //
	    // 0000 0800-0000 FFFF
	    // 1110xxxx 10xxxxxx 10xxxxxx
	    {$IFDEF LOG_UNAUTILS_ERRORS }
	    if (len <= i + 2) then
	      logMessage('unaUtils.UTF82UTF16() - not enough chars for UTF-8 value [2]');
	    {$ENDIF LOG_UNAUTILS_ERRORS }
	    //
	    if (len > i + 2) then
	      cp := (b[i + 0] and $0F) shl 12 or
		    (b[i + 1] and $3F) shl 06 or
		     b[i + 2] and $3F;
	    //
	    inc(i, 2);
	    dec(rlen, 2);
	  end
	  else begin
            //
	    if (b[i] < $F8) then begin
              //
	      // 0001 0000-001F FFFF
	      // 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
	      {$IFDEF LOG_UNAUTILS_ERRORS }
	      if (len <= i + 3) then
		logMessage('unaUtils.UTF82UTF16() - not enough chars for UTF-8 value [3]');
	      {$ENDIF LOG_UNAUTILS_ERRORS }
	      //
	      if (len > i + 3) then
		cp := (b[i + 0] and $07) shl 18 or
		      (b[i + 1] and $3F) shl 12 or
		      (b[i + 2] and $3F) shl 06 or
		      (b[i + 3] and $3F);
	      //
	      inc(i, 3);
	      dec(rlen, 3);
	    end
	    else begin
              //
	      if (b[i] < $FC) then begin
                //
		// 0020 0000-03FF FFFF
		// 111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
		{$IFDEF LOG_UNAUTILS_ERRORS }
		if (len <= i + 4) then
		  logMessage('unaUtils.UTF82UTF16() - not enough chars for UTF-8 value [4]');
		{$ENDIF LOG_UNAUTILS_ERRORS }
		//
		if (len > i + 4) then
		  cp := (b[i + 0] and $03) shl 24 or
			(b[i + 1] and $3F) shl 18 or
			(b[i + 2] and $3F) shl 12 or
			(b[i + 3] and $3F) shl 06 or
			 b[i + 4] and $3F;
		//
		inc(i, 4);
		dec(rlen, 4);
	      end
	      else begin
                //
		if (b[i] < $FE) then begin
                  //
		  // 0400 0000-7FFF FFFF
		  // 1111110x 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
		  {$IFDEF LOG_UNAUTILS_ERRORS }
		  if (len <= i + 5) then
		    logMessage('unaUtils.UTF82UTF16() - not enough chars for UTF-8 value [5]');
		  {$ENDIF LOG_UNAUTILS_ERRORS }
		  //
		  if (len > i + 5) then
		    cp := (b[i + 0] and $01) shl 30 or
			  (b[i + 1] and $3F) shl 24 or
			  (b[i + 2] and $3F) shl 18 or
			  (b[i + 3] and $3F) shl 12 or
			  (b[i + 4] and $3F) shl 06 or
			   b[i + 5] and $3F;
		  //
		  inc(i, 5);
		  dec(rlen, 5);
		end;
              end;
            end;
          end;
        end;
      end;
      //
      if (cp > $FFFF) then begin
	//
	inc(rlen);
	if (rlen > len) then
	  setLength(result, rlen);
	//
	result[rpos] := wChar(highSurrogate(cp));
	inc(rpos);
	result[rpos] := wChar(lowSurrogate(cp));
      end
      else begin
	//
	if (('' = result) and (zeroWidthNonBreakingSpace = (cp and $FFFF))) then
	  // skip initial UTF8
	else
	  result[rpos] := wChar(cp and $FFFF);
      end;
      //
      inc(i);
      inc(rpos);
    end; // while (i < len)
    //
  end;	// if (0 < len) ...
  //
  if (rlen <> len) then
    setLength(result, rlen);	// truncation may be needed
end;

// --  --
function wide2ansi(const w: wString; cp: unsigned): aString;
var
  len: int;
begin
  len := length(w);
  if (0 < len) then begin
    //
    setLength(result, len + 1);
    len := WideCharToMultiByte(cp, 0, pwChar(w), len, paChar(result), len + 1, nil, nil);
    setLength(result, len);
  end
  else
    result := '';
end;



// -- FILES --

// --  --
function ReadFile; external kernel32 name 'ReadFile';
function WriteFile; external kernel32 name 'WriteFile';

// --  --
function fileSize2str(sz: int64): string;
begin
  if (1023 < sz) then begin
    //
    if ($40000000 - 1 < sz) then
      result := int2str(sz shr 30, 10, 3, ' ') + '.'  + adjust(copy(int2str((sz shr 20) and $FFFF), 1, 2), 2, '0', true, true)  + ' GB'
    else
      if ($100000 - 1 < sz) then
	result := int2str(sz shr 20, 10, 3, ' ') + '.'  + adjust(copy(int2str((sz shr 10) and $FFFF), 1, 2), 2, '0', true, true)  + ' MB'
      else
	result := int2str(sz shr 10, 10, 3, ' ') + '.'  + adjust(copy(int2str((sz shr  0) and $FFFF), 1, 2), 2, '0', true, true)  + ' KB';
    //
  end
  else
    result := int2str(sz) + ' byte' + choice(1 < sz, 's', '');
end;

// --  --
function fileExists(const name: wString): bool;
begin
  if ('' <> name) then begin
    //
{$IFNDEF NO_ANSI_SUPPORT }
    if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
      result := ($FFFFFFFF <> GetFileAttributesW(pwChar(name)))
{$IFNDEF NO_ANSI_SUPPORT }
    else
      result := ($FFFFFFFF <> GetFileAttributesA(paChar(aString(name))));
{$ENDIF NO_ANSI_SUPPORT }
    ;
  end
  else
    result := false;
end;

// --  --
function _createFile(const fileName: wString; dwDesiredAccess, dwShareMode: DWORD; dwCreationDisposition: DWORD; dwFlagsAndAttributes: DWORD = FILE_ATTRIBUTE_NORMAL): tHandle;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
begin
{$IFNDEF NO_ANSI_SUPPORT }
  if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
    result := CreateFileW(pwChar(fileName), dwDesiredAccess, dwShareMode, nil, dwCreationDisposition, dwFlagsAndAttributes, 0)
{$IFNDEF NO_ANSI_SUPPORT }
  else
    result := CreateFileA(paChar(aString(fileName)), dwDesiredAccess, dwShareMode, nil, dwCreationDisposition, dwFlagsAndAttributes, 0);
{$ENDIF NO_ANSI_SUPPORT }
  ;
end;

// --  --
function fileCreate(const name: wString; truncate: bool; leaveOpen: bool; flags: DWORD): tHandle;
var
  cd: DWORD;
begin
  if (unaUtils.fileExists(name)) then begin
    //
    if (truncate) then
      cd := TRUNCATE_EXISTING
    else
      cd := OPEN_EXISTING;
    //
  end
  else
    cd := CREATE_NEW;
  //
  result := _createFile(name, GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, cd, flags);
  //
  if (leaveOpen) then
    // result will be either INVALID_HANDLE_VALUE or valid file handle
    // in any case we will simply return the result
  else begin
    //
    fileClose(result);	// that should not fail, but even if it will do,
    result := 0;
  end;
end;

// --  --
function fileOpen(const name: wString; wantWrites, allowSharedWrites: bool; flags: DWORD): tHandle;
begin
  result := _createFile(
    name,
    GENERIC_READ or choice(wantWrites, unsigned(GENERIC_WRITE), unsigned(0)),		// read/write?
    FILE_SHARE_READ or choice(allowSharedWrites, FILE_SHARE_WRITE, unsigned(0)),	// share
    OPEN_EXISTING,									// disposition
    flags										// override flags
  );
end;

// --  --
function fileClose(f: tHandle): bool;
begin
  if ((INVALID_HANDLE_VALUE <> f) and (0 <> f)) then
    result := CloseHandle(f)
  else
    result := false;
end;

// --  --
function fileTruncate(handle: tHandle; pos: unsigned; posMode: unsigned): bool;
begin
  if (INVALID_HANDLE_VALUE <> handle) then begin
    //
    SetFilePointer(handle, pos, nil, posMode);
    result := (SetEndOfFile(handle));
    //
  end
  else
    result := false;
end;

// --  --
function writeToFile(const name: wString; buf: pointer; size: unsigned; pos: unsigned; posMode: unsigned): int;
var
  f: tHandle;
  flags: unsigned;
begin
  result := -1;
  //
  if ('' <> name) then begin
    //
    if (unaUtils.fileExists(name)) then
      flags := OPEN_EXISTING
    else
      flags := CREATE_NEW;
    //
    f := _createFile(name, GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, flags);
    if (INVALID_HANDLE_VALUE <> f) then begin
      //
      try
	result := writeToFile(f, buf, size, pos, posMode);
      finally
	fileClose(f);
      end;
      //
    end
    else
      result := -2;
  end;
end;

// --  --
function writeToFile(const name: wString; const buf: aString; pos: unsigned; posMode: unsigned): int;
var
  nullBuf: byte;
begin
  if ('' <> buf) then
    result := writeToFile(name, @buf[1], length(buf), pos, posMode)
  else
    result := writeToFile(name, @nullBuf, 0, pos, posMode);
end;

// --  --
function writeToFile(handle: tHandle; buf: pointer; size: unsigned; pos: unsigned; posMode: unsigned): int;
var
  realSize: DWORD;
begin
  if (INVALID_HANDLE_VALUE <> handle) then begin
    //
    if ((nil <> buf) and (0 < size)) then begin
      // seek file
      SetFilePointer(handle, pos, nil, posMode);
      //
      if (WriteFile(handle, buf, size, @realSize, nil)) then
	//
	if (size = realSize) then
	  result := 0
	else
	  result := -4
      else
	result := -3;
    end
    else
      result := 0;
  end
  else
    result := -2;
end;

// --  --
function writeToFile(handle: tHandle; const buf: aString; pos: unsigned; posMode: unsigned): int;
begin
  if ('' <> buf) then
    result := writeToFile(handle, @buf[1], length(buf), pos, posMode)
  else
    result := 0;
end;

// --  --
function readFromFile(const name: wString; buf: pointer; var size: unsigned; pos: unsigned; posMode: unsigned): int;
var
  f: tHandle;
begin
  result := -1;
  if ('' <> name) then begin
    //
    f := _createFile(name, GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, OPEN_EXISTING);
    if (INVALID_HANDLE_VALUE <> f) then begin
      //
      try
	result := readFromFile(f, buf, size, pos, posMode);
      finally
	fileClose(f);
      end;
    end
    else
      result := -2;
  end;
  //
  if ((0 <> result) and (-4 <> result)) then
    size := 0;
end;

// --  --
function readFromFile(const name: wString; pos: unsigned; posMode: unsigned; len: int64): aString;
var
  sz: unsigned;
begin
  if (0 = len) then
    len := fileSize(name);
  //
  if (0 < len) then begin
    //
    setLength(result, len);
    sz := len;
    if (0 = readFromFile(name, @result[1], sz, pos, posMode)) then
      setLength(result, sz);
  end
  else
    result := '';
end;

// --  --
{
function readFromFileW(const name: wString; pos: unsigned; posMode: unsigned; len: int64): wString;
var
  sz: unsigned;
begin
  if (0 = len) then
    len := fileSize(name);
  //
  if (0 < len) then begin
    //
    setLength(result, len);
    sz := len shl 1;
    if (0 = readFromFile(name, @result[1], sz, pos, posMode)) then
      setLength(result, sz shr 1);
  end
  else
    result := '';
end;
}

// --  --
function readFromFile(handle: tHandle; buf: pointer; var size: unsigned; pos: unsigned; posMode: unsigned): int;
var
  realSize: DWORD;
begin
  if (INVALID_HANDLE_VALUE <> handle) then begin
    //
    if ((nil <> buf) and (0 < size)) then begin
      // seek file
      if ((FILE_CURRENT = posMode) and (0 = pos)) then
	// no move
      else
	//
	SetFilePointer(handle, pos, nil, posMode);
      //
      // and read it
      if (ReadFile(handle, buf, size, @realSize, nil)) then begin
	//
	if (size = realSize) then
	  result := 0
	else begin
	  //
	  size := realSize;
	  result := -4
	end;
	//
      end
      else begin
	//
	size := 0;
{$IFDEF DEBUG}
	GetLastError();
{$ENDIF}
	result := -3;
      end;
    end
    else
      result := 0;
    //
  end
  else begin
    //
    size := 0;
    result := -2;
  end;
end;

// --  --
function fileSize(const name: wString): int64;
var
  f: tHandle;
begin
  result := -1;
  if ('' <> name) then begin
    //
    f := _createFile(name, GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, OPEN_EXISTING);
    if (INVALID_HANDLE_VALUE <> f) then begin
      //
      try
	result := fileSize(f);
      finally
	fileClose(f);
      end;
    end;
  end;  
end;


const
  INVALID_FILE_SIZE = DWORD($FFFFFFFF);

// --  --
function fileSize(handle: tHandle): int64;
var
  h: DWORD;
begin
  result := -1;
  if (INVALID_HANDLE_VALUE <> handle) then begin
    //
    result := GetFileSize(handle, @h);
    if ((INVALID_FILE_SIZE = result) and (NO_ERROR <> GetLastError())) then
      //
      result := -1	// some error
    else
      inc(result, int64(h) shl 32);
  end;
end;

// --  --
function fileSeek(handle: tHandle; pos: int; posMode: unsigned): int;
begin
  if (INVALID_HANDLE_VALUE <> handle) then
    result := SetFilePointer(handle, pos, nil, posMode)
  else
    result := -1;
end;

// --  --
function fileMove(const oldName, newName: wString): bool;
begin
{$IFNDEF NO_ANSI_SUPPORT }
  if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
    result := MoveFileW(pwChar(oldName), pwChar(newName))
{$IFNDEF NO_ANSI_SUPPORT }
  else
    result := MoveFileA(paChar(aString(oldName)), paChar(aString(newName)));
{$ENDIF NO_ANSI_SUPPORT }
  ;
end;

// --  --
function fileCopy(const oldName, newName: wString; failIfExists: bool): bool;
begin
{$IFNDEF NO_ANSI_SUPPORT }
  if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
    result := CopyFileW(pwChar(oldName), pwChar(newName), failIfExists)
{$IFNDEF NO_ANSI_SUPPORT }
  else
    result := CopyFileA(paChar(aString(oldName)), paChar(aString(newName)), failIfExists);
{$ENDIF NO_ANSI_SUPPORT }
  ;
end;

// --  --
function fileDelete(const fileName: wString): bool;
begin
{$IFNDEF NO_ANSI_SUPPORT }
  if (g_wideAPIsupported) then
{$ENDIF NO_ANSI_SUPPORT }
    result := DeleteFileW(pwChar(fileName))
{$IFNDEF NO_ANSI_SUPPORT }
  else
    result := DeleteFileA(paChar(aString(fileName)));
{$ENDIF NO_ANSI_SUPPORT }
  ;
end;

// --  --
function fileChecksum(f: tHandle; crc: uint32): uint32;
var
  buf: pointer;
  maxSz: unsigned;
  totalSz: unsigned;
  sz: unsigned;
  pos: unsigned;
begin
  totalSz := fileSize(f);
  //
  if (0 < totalSz) then begin
    //
    maxSz := $1000;	// 8 sectors
    buf := malloc(maxSz);
    pos := fileSeek(f, 0, FILE_CURRENT);
    fileSeek(f);
    //
    result := crc;
    try
      repeat
	sz := min(totalSz, maxSz);
	//
	if (0 < sz) then begin
	  //
	  readFromFile(f, buf, sz);
	  result := crc32(result, buf, sz);
	  //
	  dec(totalSz, sz);
	end
	else
	  break;
	//
      until (1 > totalSz);
      //
    finally
      mrealloc(buf);
    end;
    //
    fileSeek(f, pos);
  end
  else
    result := crc32(nil, 0);
end;

// --  --
function fileChecksum(const fileName: wString): uint32;
var
  f: tHandle;
begin
  f := fileOpen(fileName);
  if (INVALID_HANDLE_VALUE <> f) then begin
    //
    try
      result := fileChecksum(f);
    finally
      fileClose(f);
    end;
  end
  else
    result := 0;
end;

// --  --
function fileModificationDateTime(const fileName: wString; useLocalTime: bool): SYSTEMTIME;
var
  f: tHandle;
begin
  f := fileOpen(fileName, false);
  try
    if (INVALID_HANDLE_VALUE <> f) then
      result := fileModificationDateTime(f, useLocalTime)
    else
      fillChar(result, sizeOf(result), 0);
  finally
    fileClose(f);
  end;
end;

// --  --
function fileModificationDateTime(f: tHandle; useLocalTime: bool): SYSTEMTIME; 
var
  ft: FILETIME;
  ok: bool;
begin
  ok := false;
  if (GetFileTime(f, nil, nil, @ft)) then begin
    //
    ok := FileTimeToSystemTime(ft, result);
    //
    if (ok and useLocalTime) then
      ok := sysDateTime2localDateTime(result, result);
  end;
  //
  if (not ok) then
    fillChar(result, sizeOf(result), 0);
end;

// --  --
function fileCreationDateTime(const fileName: wString; useLocalTime: bool = true): SYSTEMTIME;
var
  f: tHandle;
begin
  f := fileOpen(fileName, false);
  try
    if (INVALID_HANDLE_VALUE = f) then
      f := fileOpen(fileName, false, true, FILE_FLAG_BACKUP_SEMANTICS);	// try opening as directory
    //
    if (INVALID_HANDLE_VALUE <> f) then
      result := fileCreationDateTime(f, useLocalTime)
    else
      fillChar(result, sizeOf(result), 0);
    //
  finally
    fileClose(f);
  end;
end;

// --  --
function fileCreationDateTime(f: tHandle; useLocalTime: bool = true): SYSTEMTIME;
var
  ft: FILETIME;
  ok: bool;
begin
  ok := false;
  if (GetFileTime(f, @ft, nil, nil)) then begin
    //
    ok := FileTimeToSystemTime(ft, result);
    //
    if (ok and useLocalTime) then
      ok := sysDateTime2localDateTime(result, result);
  end;
  //
  if (not ok) then
    fillChar(result, sizeOf(result), 0);
end;

// --  --
//function directoryExists(const name: wString): bool;
//begin
//  result := directoryExists(name);
//end;

// --  --
function directoryExists(const name: wString): bool;
var
  code: unsigned;
begin
{$IFNDEF NO_ANSI_SUPPORT }
  if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
    code := GetFileAttributesW(pwChar(name))
{$IFNDEF NO_ANSI_SUPPORT }
  else
    code := GetFileAttributesA(paChar(aString(name)));
{$ENDIF NO_ANSI_SUPPORT }
  ;
  //
  result := ((code <> unsigned(-1)) and (code and FILE_ATTRIBUTE_DIRECTORY <> 0));
end;

// --  --
function forceDirectories(const path: wString): bool;
var
  dir: wString;
  wc: wChar;
begin
  dir := trimS(path);
  //
  if ('' <> dir) then begin
    //
    wc := dir[length(dir)];
    if ((wChar('\') = wc) or (wChar('/') = wc)) then
      delete(dir, length(dir), 1);
    //
    if ((3 > length(dir)) or directoryExists(dir) or (extractFilePath(dir) = dir)) then
      result := true
    else begin
      //
{$IFNDEF NO_ANSI_SUPPORT }
      if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
	result := (forceDirectories(extractFilePath(dir)) and CreateDirectoryW(pwChar(dir), nil))
{$IFNDEF NO_ANSI_SUPPORT }
      else
	result := (forceDirectories(extractFilePath(dir)) and CreateDirectoryA(paChar(aString(dir)), nil));
{$ENDIF NO_ANSI_SUPPORT }
      ;
    end;
  end
  else
    result := true;
end;

// --  --
function extractFilePath(const fileName: wString): wString;
begin
  result := copy(fileName, 1, lastDelimiter('/\:', fileName));
end;

// --  --
function extractFileName(const fileName: wString): wString;
begin
  result := copy(fileName, lastDelimiter('/\:', fileName) + 1, maxInt);
end;

// --  --
function changeFileExt(const fileName: wString; const ext: wString): wString;
var
  i: unsigned;
  wc: wChar;
begin
  i := length(fileName);
  //
  wc := fileName[i];
  while ((0 < i) and not ((wc = wChar('.')) or (wc = wChar('\')) or (wc = wChar('/')) or (wc = wChar(':')))) do begin
    //
    dec(i);
    wc := fileName[i];
  end;
  //
  if (0 < i) then begin
    //
    if (wChar('.') = fileName[i]) then
      result := copy(fileName, 1, int(i) - 1) + ext
    else
      result := fileName;	// cannot change ext of folder name
    //
  end
  else
    result := fileName + ext;	// no extension found - just add new one
end;

type
  proc_GetLongPathNameA = function (ShortPathName: paChar; LongPathName: paChar; cchBuffer: Integer): Integer stdcall;
  proc_GetLongPathNameW = function (ShortPathName: pwChar; LongPathName: pwChar; cchBuffer: Integer): Integer stdcall;

var
  pGLPNA: proc_GetLongPathNameA;
  pGLPNW: proc_GetLongPathNameW;

// --  --
function GetLongPathName(shortPathName: wString): wString;
var
  handle: hModule;
  wbuf: array[0 .. MAX_PATH] of wChar;
  abuf: array[0 .. MAX_PATH] of aChar;
begin
  result := shortPathName;
  //
{$IFNDEF NO_ANSI_SUPPORT }
  if (not g_wideApiSupported and not assigned(pGLPNA)) then begin
    //
    handle := GetModuleHandle(kernel32);
    if (0 <> handle) then
      pGLPNA := GetProcAddress(Handle, 'GetLongPathNameA');
  end;
{$ENDIF NO_ANSI_SUPPORT }
  //
  if ({$IFNDEF NO_ANSI_SUPPORT }g_wideApiSupported and {$ENDIF NO_ANSI_SUPPORT }not assigned(pGLPNW)) then begin
    //
    handle := GetModuleHandle(kernel32);
    if (0 <> handle) then
      pGLPNW := GetProcAddress(Handle, 'GetLongPathNameW');
  end;
  //
  if ({$IFNDEF NO_ANSI_SUPPORT }g_wideApiSupported and {$ENDIF NO_ANSI_SUPPORT }assigned(pGLPNW)) then begin
    //
    pGLPNW(pwChar(shortPathName), wbuf, MAX_PATH);
    result := wbuf;
  end
  else begin
    //
    if (assigned(pGLPNA)) then begin
      //
      pGLPNA(paChar(aString(shortPathName)), abuf, MAX_PATH);
      result := wString(abuf);
    end;
  end;  
end;


function SHGetMalloc;                   external 'shell32.dll' name 'SHGetMalloc';
function SHGetDesktopFolder;            external 'shell32.dll' name 'SHGetDesktopFolder';
function SHBrowseForFolderA;          	external 'shell32.dll' name 'SHBrowseForFolderA';
function SHBrowseForFolderW;          	external 'shell32.dll' name 'SHBrowseForFolderW';
function SHGetPathFromIDListA;        	external 'shell32.dll' name 'SHGetPathFromIDListA';
function SHGetPathFromIDListW;        	external 'shell32.dll' name 'SHGetPathFromIDListW';

// --  --
function selectDirCB(wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): integer stdcall;
begin
  if ((BFFM_INITIALIZED = uMsg) and (0 <> lpData)) then begin
    //
{$IFNDEF NO_ANSI_SUPPORT }
    if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
      sendMessageW(wnd, BFFM_SETSELECTION, Integer(True), lpData)
{$IFNDEF NO_ANSI_SUPPORT }
    else
      sendMessageA(wnd, BFFM_SETSELECTION, Integer(True), lpData);
{$ENDIF NO_ANSI_SUPPORT }
    ;
  end;
  //
  result := 0;
end;

// --  --
function guiSelectDirectory(const caption, root: wString; var directory: wString; handle: hWnd; flags: uint): bool;
var
  //windowList: pointer;
  browseInfoW: tBrowseInfoW;
{$IFNDEF NO_ANSI_SUPPORT }
  browseInfoA: tBrowseInfoA;
{$ENDIF NO_ANSI_SUPPORT }
  //
  bufW: pwChar;
{$IFNDEF NO_ANSI_SUPPORT }
  bufA: paChar;
{$ENDIF NO_ANSI_SUPPORT }
  //
  oldErrorMode: cardinal;
  //
  rootItemIDList,
  itemIDList: pItemIDList;
  //
  shellMalloc: iMalloc;
  desktopFolder: iShellFolder;
  //
  eaten: DWORD;
  attrs: DWORD;
  //
  {$IFDEF DEBUG }
  mem: array[byte] of aChar;
  {$ENDIF DEBUG }
begin
  result := false;
  //
  if (not directoryExists(directory)) then
    directory := '';
  //
{$IFNDEF NO_ANSI_SUPPORT }
  if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
    fillChar(browseInfoW, sizeof(tBrowseInfoW), 0)
{$IFNDEF NO_ANSI_SUPPORT }
  else
    fillChar(browseInfoA, sizeof(tBrowseInfoA), 0);
{$ENDIF NO_ANSI_SUPPORT }
  ;
  //
  shellMalloc := nil;
  if ((S_OK = ShGetMalloc(shellMalloc)) and (nil <> shellMalloc)) then begin
    //
{$IFNDEF NO_ANSI_SUPPORT }
    if (g_wideApiSupported) then begin
{$ENDIF NO_ANSI_SUPPORT }
      //
      bufW := shellMalloc.Alloc(MAX_PATH * sizeOf(wChar));
{$IFNDEF NO_ANSI_SUPPORT }
      bufA := nil;	// to make compiler happy
    end
    else begin
      //
      bufA := shellMalloc.Alloc(MAX_PATH * sizeOf(aChar));
      bufW := nil;	// to make compiler happy
    end;
{$ENDIF NO_ANSI_SUPPORT }
    //
    try
      rootItemIDList := nil;
      if ('' <> root) then begin
	//
        attrs := 0;
        desktopFolder := nil;
	if (NOERROR = SHGetDesktopFolder(desktopFolder)) then
	  desktopFolder.ParseDisplayName(handle, nil, pwChar(root), eaten, rootItemIDList, attrs);
	//
      end;
      //
{$IFNDEF NO_ANSI_SUPPORT }
      if (g_wideApiSupported) then begin
{$ENDIF NO_ANSI_SUPPORT }
	//
	with browseInfoW do begin
	  //
	  hwndOwner := handle;
	  pidlRoot := rootItemIDList;
	  pszDisplayName := bufW;
	  lpszTitle := pwChar(caption);
	  ulFlags := flags;
	  //
	  if ('' <> directory) then begin
	    //
	    lpfn := selectDirCB;
	    //
	    // -- for some reason Windows always expects Ansi aString here --
	    //
	    //lParam := Windows.LPARAM(pointer(directory));
	    //
	    lParam := Windows.LPARAM(paChar(aString(directory)));
	  end;
	end;
	//
{$IFNDEF NO_ANSI_SUPPORT }
      end
      else begin
	//
	with BrowseInfoA do begin
	  //
	  hwndOwner := handle;
	  pidlRoot := rootItemIDList;
	  pszDisplayName := bufA;
	  lpszTitle := paChar(aString(caption));
	  ulFlags := flags;
	  //
	  if ('' <> directory) then begin
	    //
	    lpfn := selectDirCB;
	    lParam := Windows.LPARAM(paChar(aString(directory)));
	  end;
	end;
	//
      end;
{$ENDIF NO_ANSI_SUPPORT }
      //
      oldErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
      try
{$IFNDEF NO_ANSI_SUPPORT }
	if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
	  itemIDList := ShBrowseForFolderW(browseInfoW)
{$IFNDEF NO_ANSI_SUPPORT }
	else
	  itemIDList := ShBrowseForFolderA(browseInfoA);
{$ENDIF NO_ANSI_SUPPORT }
        ;
	//
      finally
	SetErrorMode(oldErrorMode);
      end;
      //
      result :=  (nil <> itemIDList);
      //
      if (result) then begin
	//
{$IFNDEF NO_ANSI_SUPPORT }
	if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
	  ShGetPathFromIDListW(ItemIDList, BufW)
{$IFNDEF NO_ANSI_SUPPORT }
	else
	  ShGetPathFromIDListA(ItemIDList, BufA);
{$ENDIF NO_ANSI_SUPPORT }
        ;
	//
	shellMalloc.Free(ItemIDList);
	//
{$IFNDEF NO_ANSI_SUPPORT }
	if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
	  directory := bufW
{$IFNDEF NO_ANSI_SUPPORT }
	else
	  directory := wString(bufA);
{$ENDIF NO_ANSI_SUPPORT }
        ;
	//
	{$IFDEF DEBUG }
	if ('' <> directory) then
	  move(directory[1], mem[0], 256);
	{$ENDIF DEBUG }
      end;
      //
    finally
{$IFNDEF NO_ANSI_SUPPORT }
      if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
	shellMalloc.Free(bufW)
{$IFNDEF NO_ANSI_SUPPORT }
      else
	shellMalloc.Free(bufA);
{$ENDIF NO_ANSI_SUPPORT }
      ;
    end;
  end;
end;


// --  --
function paramStrW(index: unsigned): wString;

  // --  --
  function skipParam(var p: pwChar; var len: int; out start: pwChar): unsigned;
  var
    inString: bool;
    firstString: bool;
  begin
    inString := false;
    start := p;
    result := 0;
    firstString := false;
    //
    while (0 < len) do begin
      //
      case (p[0]) of

	'"': begin
	  //
	  if (not inString) then begin
	    //
	    inString := true;
	    //
	    if (start = p) then begin
	      //
	      firstString := true;
	      inc(start)
	    end
	    else
	      inc(result);
	  end
	  else begin
	    //
	    if (not firstString) then
	      inc(result);
	    //  
	    inString := false;
	  end;
	end;

	' ':  begin
	  //
	  if (inString) then
	    inc(result)
	  else begin
	    //
	    if (start = p) then
	      inc(start)
	    else
	      break;
	  end;
	end;

	else begin
	  //
	  inc(result);
	end;

      end;	// case
      //
      inc(p);
      dec(len);
    end;
  end;

var
  p: pwChar;
  len: int;
  size: unsigned;
  start: pwChar;
begin
  p := GetCommandLineW();
  len := min(length(p), 4095);
  //
  size := 0;
  //
  while (0 < len) do begin
    //
    size := skipParam(p, len, start);
    //
    if (0 < index) then begin
      //
      start := p;	// ensure last parameter will not take wrong start/size pair
      size := 0;
      dec(index);
    end
    else
      break;
  end;
  //
  setLength(result, size);
  if (0 < size) then
    move(start^, result[1], size shl 1);
end;

// --  --

{$IFDEF FPC }
{$ELSE }
type
  PULARGE_INTEGER = ^LARGE_INTEGER;
  LARGE_INTEGER = packed record
    case Integer of
    0: (
      LowPart: DWORD;
      HighPart: Longint);
    1: (
      QuadPart: LONGLONG);
  end;

{$ENDIF FPC }

function GetDiskFreeSpaceExA(lpDirectoryName: paChar; lpFreeBytesAvailableToCaller, lpTotalNumberOfBytes, lpTotalNumberOfFreeBytes: PULARGE_INTEGER): BOOL; stdcall; external kernel32 name 'GetDiskFreeSpaceExA';
function GetDiskFreeSpaceExW(lpDirectoryName: pwChar; lpFreeBytesAvailableToCaller, lpTotalNumberOfBytes, lpTotalNumberOfFreeBytes: PULARGE_INTEGER): BOOL; stdcall; external kernel32 name 'GetDiskFreeSpaceExW';

// --  --
function getDiskSpace(const path: wString; index: int): int64;
var
  dir: wString;
  res: bool;
  avail,
  total,
  free: ULARGE_INTEGER;
begin
  if (1 < length(path)) then begin
    //
    if (':' = path[2]) then
      dir := copy(path, 1, 3)
    else
      dir := path;
    //
{$IFNDEF NO_ANSI_SUPPORT }
    if (g_wideAPISupported) then
{$ENDIF NO_ANSI_SUPPORT }
      res := GetDiskFreeSpaceExW(pwChar(dir), pULARGE_INTEGER(@avail), pULARGE_INTEGER(@total), pULARGE_INTEGER(@free))
{$IFNDEF NO_ANSI_SUPPORT }
    else
      res := GetDiskFreeSpaceExA(paChar(aString(dir)), pULARGE_INTEGER(@avail), pULARGE_INTEGER(@total), pULARGE_INTEGER(@free));
{$ENDIF NO_ANSI_SUPPORT }
    ;
    //
    if (res) then begin
      //
      case (index) of

	0: result := avail.QuadPart;
	1: result := total.QuadPart;
	2: result := free.QuadPart;

	else
	  result := -1;

      end;
    end
    else
      result := -1;
  end
  else
    result := -1;    
end;

// --  --
function addBackSlash(const path: wString): wString;
var
  l: int;
  wc: wChar;
begin
  l := length(path);
  if (l > 0) then begin
    //
    while ((l > 1) and (' ' = path[l])) do
      dec(l);
    //
    wc := path[l];
    if (not ((wc = wChar('/')) or (wc = wChar('\')) or (wc = wChar(':')))) then
      result := copy(path, 1, l) + wChar('\')
    else
      result := copy(path, 1, l);
    //
  end
  else
    result := '';
end;

function SHGetSpecialFolderPathA; external 'shell32.dll' name 'SHGetSpecialFolderPathA';
function SHGetSpecialFolderPathW; external 'shell32.dll' name 'SHGetSpecialFolderPathW';

// --  --
function getSpecialFolderPath(nFolder: int; owner: hWnd; doCreate: bool): wString;
var
{$IFNDEF NO_ANSI_SUPPORT }
  bufA: array[0..MAX_PATH] of aChar;
{$ENDIF NO_ANSI_SUPPORT }
  bufW: array[0..MAX_PATH] of wChar;
begin
  result := '';
  //
{$IFNDEF NO_ANSI_SUPPORT }
  if (g_wideApiSupported) then begin
{$ENDIF NO_ANSI_SUPPORT }
    //
    if (SHGetSpecialFolderPathW(owner, bufW, nFolder, doCreate)) then
      result := bufW;
    //
{$IFNDEF NO_ANSI_SUPPORT }
  end
  else begin
    //
    if (SHGetSpecialFolderPathA(owner, bufA, nFolder, doCreate)) then
      result := wString(bufA);
    //
  end;
{$ENDIF NO_ANSI_SUPPORT }
end;

// --  --
function getAppDataFolderPath(owner: hWnd; doCreate: bool): wString;
begin
  result := addBackSlash(getSpecialFolderPath(CSIDL_APPDATA, owner, doCreate));
end;

// --  --
function hostName(): wString;
var
{$IFDEF NO_ANSI_SUPPORT }
{$ELSE }
  nameA: array[byte] of aChar;
{$ENDIF NO_ANSI_SUPPORT }
  nameW: array[byte] of wChar;
  sz: unsigned;
begin
  sz := 255;
{$IFNDEF NO_ANSI_SUPPORT }
  if (g_wideApiSupported) then begin
{$ENDIF NO_ANSI_SUPPORT }
    GetComputerNameW(nameW, sz);
{$IFNDEF NO_ANSI_SUPPORT }
  end
  else begin
    //
    GetComputerNameA(nameA, sz);
{$IFDEF __BEFORE_D6__ }
    str2arrayW(wString(nameA), nameW);
{$ELSE }
    str2array(wString(nameA), nameW);
{$ENDIF __BEFORE_D6__ }
  end;
{$ENDIF NO_ANSI_SUPPORT }
  //
  result := nameW;
end;

// --  --
procedure ff(const path, mask: wString; callback: proc_ffcallback; includeSubfolders: bool; sfonly: bool; const omask: wString; sender: pointer);
var
  res: tHandle;
  arg: wString;
  fdw: TWIN32FINDDATAW;
{$IFNDEF NO_ANSI_SUPPORT }
  fda: TWIN32FINDDATAA;
{$ENDIF NO_ANSI_SUPPORT }
  more: bool;
  isFolder: bool;
  isDummy: bool;
  name: wString;
begin
  if (not sfonly and includeSubfolders and ('*.*' <> mask)) then
    // process subfolders
    ff(path, '*.*', callback, true, true, mask, sender);
  //
  arg := addBackSlash(path) + mask;
  //
{$IFNDEF NO_ANSI_SUPPORT }
  if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
    res := FindFirstFileW(pwChar(arg), fdw)
{$IFNDEF NO_ANSI_SUPPORT }
  else
    res := FindFirstFileA(paChar(aString(arg)), fda);
{$ENDIF NO_ANSI_SUPPORT }
  ;
  //
  if (INVALID_HANDLE_VALUE <> res) then begin
    //
    try
      //
      more := true;
      while (more) do begin
	//
{$IFNDEF NO_ANSI_SUPPORT }
	if (not g_wideApiSupported) then begin
	  //
	  move(fda, fdw, sizeOf(fda) - sizeOf(fda.cFileName) - sizeOf(fda.cAlternateFileName));
          {$IFDEF __BEFORE_D6__ }
	  str2arrayW(wString(fda.cFileName),          fdw.cFileName);
	  str2arrayW(wString(fda.cAlternateFileName), fdw.cAlternateFileName);
          {$ELSE }
	  str2array(wString(fda.cFileName),          fdw.cFileName);
	  str2array(wString(fda.cAlternateFileName), fdw.cAlternateFileName);
          {$ENDIF __BEFORE_D6__ }
	end;
{$ENDIF NO_ANSI_SUPPORT }
	//
	name := fdw.cFileName;
	isFolder := (0 <> (FILE_ATTRIBUTE_DIRECTORY and fdw.dwFileAttributes));
	isDummy := ('.' = name) or ('..' = name);
	//
	if (not sfonly or includeSubfolders and isFolder) then
	  callback(sender, path, fdw);
	//
	if (includeSubfolders and isFolder and not isDummy) then
	  // found a subfolder, process it first
	  ff(addBackSlash(path) + name, choice(sfonly, omask, mask), callback, true, false, '', sender);
	//
{$IFNDEF NO_ANSI_SUPPORT }
	if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
	  more := FindNextFileW(res, fdw)
{$IFNDEF NO_ANSI_SUPPORT }
	else
	  more := FindNextFileA(res, fda);
{$ENDIF NO_ANSI_SUPPORT }
        ;
	//
      end;
      //
    finally
      Windows.FindClose(res);
    end;
  end;
end;

// --  --
procedure findFiles(const path, mask: wString; callback: proc_ffcallback; includeSubfolders: bool; sender: pointer);
begin
  ff(path, mask, callback, includeSubfolders, false, '', sender);
end;

// --  --
function folderRemoveFiles(const path: wString; includeSubfolders: bool; const mask: wString; removeSubfoldersAsWell, SFONLY: bool; const omask: wString): bool;
var
  res: tHandle;
  arg: wString;
  fdw: TWIN32FINDDATAW;
{$IFNDEF NO_ANSI_SUPPORT }
  fda: TWIN32FINDDATAA;
{$ENDIF NO_ANSI_SUPPORT }
  more: bool;
  isFolder: bool;
  isDummy: bool;
  name: wString;
begin
  if (not SFONLY and includeSubfolders and ('*.*' <> mask)) then
    folderRemoveFiles(path, true, '*.*', removeSubfoldersAsWell, true, mask);
  //
  arg := addBackSlash(path) + mask;
  //
{$IFNDEF NO_ANSI_SUPPORT }
  if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
    res := FindFirstFileW(pwChar(arg), fdw)
{$IFNDEF NO_ANSI_SUPPORT }
  else
    res := FindFirstFileA(paChar(aString(arg)), fda);
{$ENDIF NO_ANSI_SUPPORT }
  ;
  //
  result := false;
  if (INVALID_HANDLE_VALUE <> res) then begin
    //
    try
      //
      more := true;
      while (more) do begin
	//
{$IFNDEF NO_ANSI_SUPPORT }
	if (g_wideApiSupported) then begin
{$ENDIF NO_ANSI_SUPPORT }
	  //
	  name := fdw.cFileName;
	  isFolder := (0 <> (FILE_ATTRIBUTE_DIRECTORY and fdw.dwFileAttributes));
{$IFNDEF NO_ANSI_SUPPORT }
	end
	else begin
	  //
	  name := wString(fda.cFileName);
	  isFolder := (0 <> (FILE_ATTRIBUTE_DIRECTORY and fda.dwFileAttributes));
	end;
{$ENDIF NO_ANSI_SUPPORT }
	//
	isDummy := ('.' = name) or ('..' = name);
	//
	if (includeSubfolders and isFolder and not isDummy) then
	  folderRemoveFiles(addBackSlash(path) + name, true, choice(SFONLY, omask, mask), removeSubfoldersAsWell);
	//
	// do removal, if needed
	if (isFolder) then begin
	  //
	  if (removeSubfoldersAsWell and not isDummy) then
	    folderRemove(addBackSlash(path) + name);
          //
	end
	else
	  if (SFONLY) then
	    // do not touch files when working with folders only
	  else
	    fileDelete(addBackSlash(path) + name);
	//
{$IFNDEF NO_ANSI_SUPPORT }
	if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
	  more := FindNextFileW(res, fdw)
{$IFNDEF NO_ANSI_SUPPORT }
	else
	  more := FindNextFileA(res, fda);
{$ENDIF NO_ANSI_SUPPORT }
        ;
	//
      end;
      //
    finally
      Windows.FindClose(res);
    end;
  end;
end;

// --  --
function folderRemove(const path: wString): bool;
begin
{$IFNDEF NO_ANSI_SUPPORT }
  if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
    result := RemoveDirectoryW(pwChar(path))
{$IFNDEF NO_ANSI_SUPPORT }
  else
    result := RemoveDirectoryA(paChar(aString(path)));
{$ENDIF NO_ANSI_SUPPORT }
  ;
end;

// --  --
function getTempFileName(const prefix: wString = 'una'): wString;	// same as above
begin
  result := getTemporaryFileName(prefix);
end;

// --  --
function getTemporaryFileName(const prefix: wString): wString;
var
  res: DWORD;
  ok: bool;
  tmpPathW: array[0..MAX_PATH] of wChar;
  tmpFileW: array[0..MAX_PATH] of wChar;
{$IFNDEF NO_ANSI_SUPPORT }
  tmpPathA: array[0..MAX_PATH] of aChar;
  tmpFileA: array[0..MAX_PATH] of aChar;
{$ENDIF NO_ANSI_SUPPORT }
begin
  ok := false;
  //
{$IFNDEF NO_ANSI_SUPPORT }
  if (g_wideApiSupported) then begin
{$ENDIF NO_ANSI_SUPPORT }
    //
    if (not ok) then begin
      // 1.
      res := ExpandEnvironmentStringsW('%TMP%', tmpPathW, sizeOf(tmpPathW));
      ok := (0 <> res) and directoryExists(tmpPathW);
    end;
    //
    if (not ok) then begin
      // 2.
      res := ExpandEnvironmentStringsW('%TEMP%', tmpPathW, sizeOf(tmpPathW));
      ok := (0 <> res) and directoryExists(tmpPathW);
    end;
    //
    if (not ok) then begin
      // 3.
      res := GetWindowsDirectoryW(tmpPathW, sizeOf(tmpPathW));
      {$IFDEF __BEFORE_D6__ }
      str2arrayW(tmpPathW + '\temp\', tmpPathW);
      {$ELSE }
      str2array(tmpPathW + '\temp\', tmpPathW);
      {$ENDIF __BEFORE_D6__ }
      ok := (0 <> res) and directoryExists(tmpPathW);
    end;
    //
    if (not ok) then begin
      // 4.
      res := GetTempPathW(MAX_PATH, tmpPathW);
      ok := (0 <> res) and directoryExists(tmpPathW);
    end;
    //
    if (ok and (0 <> GetTempFileNameW(tmpPathW, pwChar(prefix), 0, tmpFileW))) then
      result := tmpFileW
    else
      result := '';
{$IFNDEF NO_ANSI_SUPPORT }
  end
  else begin
    // ANSI
    if (not ok) then begin
      // 1.
      res := ExpandEnvironmentStringsA('%TMP%', tmpPathA, sizeOf(tmpPathA));
      ok := (0 <> res) and directoryExists(string(tmpPathA));
    end;
    //
    if (not ok) then begin
      // 2.
      res := ExpandEnvironmentStringsA('%TEMP%', tmpPathA, sizeOf(tmpPathA));
      ok := (0 <> res) and directoryExists(string(tmpPathA));
    end;
    //
    if (not ok) then begin
      // 3.
      res := GetWindowsDirectoryA(tmpPathA, sizeOf(tmpPathA));
      str2array(tmpPathA + aString('\temp\'), tmpPathA);
      ok := (0 <> res) and directoryExists(string(tmpPathA));
    end;
    //
    if (not ok) then begin
      // 4.
      res := GetTempPathA(MAX_PATH, tmpPathA);
      ok := (0 <> res) and directoryExists(string(tmpPathA));
    end;
    //
    if (ok and (0 <> GetTempFileNameA(tmpPathA, paChar(aString(prefix)), 0, tmpFileA))) then
      result := wString(tmpFileA)
    else
      result := '';
  end;
{$ENDIF NO_ANSI_SUPPORT }
end;



// --  --
function bool2int(value: bool): int;
begin
  result := ord(value);
end;

// --  --
function bool2str(value: bool): string;
begin
  result := int2str(bool2Int(value));
end;

// --  --
function bool2strStr(value: bool): string;
begin
  if (value) then
    result := 'true'
  else
    result := 'false';
end;

// --  --
function int2bool(value: int): bool;
begin
  result := not (ord(false) = value);
end;


var
  g_thousandSeparatorA: aChar = ' ';
  g_thousandSeparatorW: wChar = ' ';
  g_thousandSeparator: char = ' ';


// --  --
procedure fillLocale();
var
  bufA: array[0..1] of aChar;
  bufW: array[0..1] of wChar;
begin
  if (GetLocaleInfoA(GetThreadLocale(), LOCALE_STHOUSAND, bufA, 2) > 0) then
    g_thousandSeparatorA := bufA[0]
  else
    g_thousandSeparatorA := ',';
  //
  if (GetLocaleInfoW(GetThreadLocale(), LOCALE_STHOUSAND, bufW, 2) > 0) then
    g_thousandSeparatorW := bufW[0]
  else
    g_thousandSeparatorW := ',';
  //
{$IFDEF __BEFORE_DC__ }
  g_thousandSeparator := g_thousandSeparatorA;
{$ELSE }
  g_thousandSeparator := g_thousandSeparatorW;
{$ENDIF __BEFORE_DC__ }
end;

{$IFNDEF CPU64 }

// --  --
function int2str(value: int; base: unsigned; split: unsigned; splitchar: char): string;
begin
  result := int2str(int64(value), base, split, splitchar);
end;

{$ENDIF CPU64 }

const
  c_base_str = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz[]<>&$#';

// -- --
function abs64(v: int64): int64;
begin
  if (v < 0) then
    result := -v
  else
    result := v;
end;

// -- --
function int2str(const value: int64; base: unsigned; split: unsigned; splitchar: char): string;
const
  digits: string = c_base_str;
var
  i: int;
  v: int64;
begin
  if (0 = value) then
    result := '0'
  else
    result := '';
  //
  if ((1 < base) and (unsigned(length(digits)) > base)) then begin
    //
    v := value;
    while (0 <> v) do begin
      //
      result := digits[abs64(v mod base) + 1] + result;
      v := v div base;
    end;
  end;
  //
  if (split > 0) then begin
    //
    if (' ' = splitchar) then
      splitchar := g_thousandSeparator;
    //
    i := length(result) - int(split) + 1;
    while (i > 1) do begin
      //
      insert(splitchar, result, i);
      dec(i, split);
    end;
  end;
  //
  if (0 > value) then
    result := '-' + result;
end;

// -- --
function int2str(value: word; base: unsigned; split: unsigned; splitchar: char): string;
begin
  result := int2str(unsigned(value), base, split, splitchar);
end;

// -- --
function int2str(value: unsigned; base: unsigned; split: unsigned; splitchar: char): string;
begin
  result := int2str(int64(value), base, split, splitchar);
end;

// --  --
function intArray2str(value: pInt32Array): string;
var
  i: int;
begin
  result := '';
  //
  if (nil <> value) then begin
    //
    i := 0;
    while (i < value[0]) do begin
      //
      result := result + int2str(value[i + 1]) + ',';
      //
      inc(i);
    end;
  end;
end;

// --  --
function str2bool(const value: string; defValue: bool): bool;
begin
  result := int2bool(str2IntInt(value, bool2Int(defValue)));
end;

// --  --
function strStr2bool(const value: string; defValue: bool): bool;
begin
  if ('true' = lowerCase(value)) then           // this "string" must not be replaced with aString
    result := true
  else
    if ('false' = lowerCase(value)) then        // this "string" must not be replaced with aString
      result := false
    else
      result := defValue;
end;

// --  --
function str2intByte(const value: string; defValue: byte; base: unsigned; ignoreTrails: bool): byte;
begin
  result := byte(str2intInt64(value, int64(defValue), base, ignoreTrails));
end;

// --  --
function str2intInt(const value: string; defValue: int; base: unsigned; ignoreTrails: bool): int;
begin
  result := int(str2intInt64(value, int64(defValue), base, ignoreTrails));
end;

// --  --
function str2intUnsigned(const value: string; defValue: unsigned; base: unsigned; ignoreTrails: bool): unsigned;
begin
  result := unsigned(str2intInt64(value, int64(defValue), base, ignoreTrails));
end;

// --  --
function str2intInt64(const value: string; defValue: int64; base: unsigned; ignoreTrails: bool): int64;
begin
  if ('' <> value) then
    result := str2intInt64(@value[1], length(value), defValue, base, ignoreTrails)
  else
    result := defValue;
end;

// --  --
function str2intInt64(value: pChar; maxLen: int; defValue: int64; base: unsigned; ignoreTrails: bool): int64;

  // --  --
  function charInAZ19(c: char): bool;
  begin
    {$IFDEF __BEFORE_DC__ }
    result := (c in ['1'..'9', 'A'..'Z', 'a'..'z']);
    {$ELSE }
    result := ((c >= '1') and (c <= '9')) or
	      ((c >= 'A') and (c <= 'Z')) or
	      ((c >= 'a') and (c <= 'z'));
    {$ENDIF __BEFORE_DC__ }
  end;

var
  sign: int;
  sApplied: bool;
  ok: bool;
  b: byte;
  ofs: int64;
  c: char;
begin
  result := defValue;
  if ((nil <> value) and (#0 <> value) and (0 < maxLen) and (1 < base) and (36 >= base)) then begin
    //
    sign := 1;
    sApplied := false;
    //
    // trim leading spaces
    while ((0 < maxLen) and (' ' = value^)) do begin
      //
      inc(value);
      dec(maxLen);
    end;
    //
    // trim trailing spaces
    while ((0 < maxLen) and (' ' = value[maxLen - 1])) do
      dec(maxLen);
    //
    if ((10 = base) and
	( ('$' = value^) or
	  ('h' = value[maxLen - 1]) or
	  ('H' = value[maxLen - 1]) or
	  ( ('0' = value^) and (('x' = value[1]) or ('X' = value[1])) )
	)
       ) then begin
      //
      case (value^) of

	'$': begin
	  //
	  inc(value);
	  dec(maxLen);
	end;

	'0': begin
	  //
	  inc(value, 2);
	  dec(maxLen, 2);
	end;

	else
	  dec(maxLen);	// ignore trailing 'H'

      end;
    end;
    //
    ok := true;
    while ((16 >= base) and (0 < maxLen) and not charInAZ19(value^)) do begin
      //
      case (value^) of

	'-':
	  sign := -1;

	'+':
	  sign := +1;

	'0':
	  ;	// skip leading zeroes

	else begin
	  //
	  ok := false;	// have found some invalid character
	  break;
	end;

      end;
      //
      inc(value);
      dec(maxLen);
    end;
    //
    if (ok) then begin
      //
      result := 0;
      ofs := 1;
      while (0 < maxLen) do begin
	//
	c := value[maxLen - 1];
	case (c) of

	  '0'..'9': b := ord(c) - ord('0');
	  'A'..'Z': b := ord(c) - ord('A') + 10;
	  'a'..'z': b := ord(c) - ord('a') + 10;

	  else begin
	    //
	    b := 0;	// to avoid compiler warnings
	    ok := false;
	  end;

	end;	// case
	//
	if (ok or ignoreTrails) then begin
	  //
	  if (ok) then begin
	    //
	    if ((1 = maxLen) and (0 > sign)) then begin
	      //
	      ofs := -ofs;
	      result := -result;
	      sApplied := true;
	    end;
	    //
	    result := result + ofs * b;
	    ofs := ofs * base;
	  end
	  else begin
	    //
	    ofs := 1;
	    result := 0;
	    ok := true;	// try from next char
	  end;
          //
	  dec(maxLen);
	  //inc(value);
	end
	else
	  break;
      end;
      //
      if (ok) then begin
        //
        if (not sApplied) then
          result := sign * result   // already done
      end
      else
	result := defValue;
    end;
    //
  end;
end;

// --  --
function str2intArray(const value: string; subLevel: int): pInt32Array;

  // --  --
  function nextInt(var pos: int; len, subLevel: int): string;
  var
    s: int;
    e: int;
  begin
    if (0 = subLevel) then
      s := pos
    else
      s := -1;
    //
    e := -1;
    //
    while (pos <= len) do begin
      //
      case (value[pos]) of

	',': begin
	  //
	  if (0 > e) then
	    e := pos;
	  //
	  break;
	end;

	':': begin
	  //
	  if (0 = subLevel) then
	    e := pos;
	  //
	  dec(subLevel);
	end;

	else begin
	  //
	  if ((0 > s) and (0 = subLevel)) then
	    s := pos;
	  //
	end;


      end;
      //
      inc(pos);
      //
    end;	// while ()...
    //
    if (0 > e) then
      e := pos;
    //
    if (0 < s) then
      result := trimS(copy(value, s, e - s))
    else
      result := '';
  end;

var
  i: int;
  len: int;
  num: string;
begin
  result := malloc(sizeOf(int));
  result[0] := 0;
  //
  i := 1;
  len := length(value);
  while (i <= len) do begin
    //
    num := nextInt(i, len, subLevel);
    //
    inc(result[0]);
    mrealloc(result, (1 + result[0]) * sizeOf(int));
    result[result[0]] := str2intInt(num, 0);
    //
    inc(i);
  end;
end;


type
  RPC_STATUS = long;

//#	define  RPC_ENTRY __stdcall

//function UuidCreate(var Uuid: TUUID): RPC_STATUS; stdcall; external

const
  ole32    = 'ole32.dll';

function CoCreateGuid(out guid: TGUID): HResult; stdcall; external ole32 name 'CoCreateGuid';
function StringFromCLSID(const clsid: TGUID; out psz: pwChar): HResult; stdcall; external ole32 name 'StringFromCLSID';
procedure CoTaskMemFree(pv: Pointer); stdcall; external ole32 name 'CoTaskMemFree';

// --  --
function newGUID(): string;
var
  res: HRESULT;
  guid: TGUID;
  P: pwChar;
begin
  res := CoCreateGuid(guid);
  if (Succeeded(res)) then begin
    //
    if (Succeeded(StringFromCLSID(GUID, P))) then begin
      //
      result := string(P);
      CoTaskMemFree(P);
    end
    else
      result := int2str(guid.D1) + '-' + int2str(guid.D2) + '-' + int2str(guid.D3);
    //
  end
  else
    result := int2str(random(maxInt)) + '-' + int2str(random(maxWord)) + '-' + int2str(random(maxWord));
end;

// --  --
function sameGUIDs(const g1, g2: tGuid): bool;
begin
  result := mcompare(@g1, @g2, sizeOf(g1));
end;


// --  --
procedure ms2time(ms: int64; out dd, hh, mm, ss, mss: unsigned);
begin
  dd := (ms div 86400000);
  hh := (ms div 3600000 ) mod 24;
  mm := (ms div 60000   ) mod 60;
  ss := (ms div 1000    ) mod 60;
  mss := ms mod 1000;
end;

{$IFDEF __SYSUTILS_H_ }
{$ELSE }

// --  --
function encodeTime(hh, mm, ss, ms: unsigned): tDateTime;
begin
  if (hh < 24) and (mm < 60) and (ss < 60) and (ms < 1000) then begin
    //
    result := (hh * (60 * 60 * 1000) +
	       mm * (60 * 1000) +
	       ss * (1000) +
	       ms) / (24 * 60 * 60 * 1000);
  end
  else
    result := 0;
end;

{$ENDIF __SYSUTILS_H_ }

// --  --
function ms2dateTime(ms: int64): tDateTime;
var
  dd, hh, mm, ss, mss: unsigned;
begin
  ms2time(ms, dd, hh, mm, ss, mss);
  //
  result := dd + encodeTime(hh, mm, ss, mss);
end;

// --  --
function dateTime2b64str(const dateTime: tDateTime): string;
begin
  result := string(base64encode(@dateTime, sizeOf(dateTime)));
end;

// --  --
function b64str2dateTime(const date: string; const defValue: tDateTime = 0): tDateTime;
var
  res: string;
begin
  res := string(base64decode(aString(date)));
  if (sizeOf(result) = length(res)) then
    move(res[1], result, sizeOf(result))
  else
    result := defValue;
end;

// --  --
function sysTime2str(time: pSYSTEMTIME; const format: wString; locale: LCID; flags: DWORD): wString;
var
{$IFNDEF NO_ANSI_SUPPORT }
  bufA: array[0..1024] of aChar;
{$ENDIF NO_ANSI_SUPPORT }
  bufW: array[0..1024] of wChar;
  //
  fmtW: pwChar;
{$IFNDEF NO_ANSI_SUPPORT }
  fmtA: paChar;
{$ENDIF NO_ANSI_SUPPORT }
  res: int;
begin
  if ('' = format) then begin
    //
    fmtW := nil;
{$IFNDEF NO_ANSI_SUPPORT }
    fmtA := nil;
{$ENDIF NO_ANSI_SUPPORT }
  end
  else begin
    //
    fmtW := pwChar(format);
{$IFNDEF NO_ANSI_SUPPORT }
    fmtA := paChar(aString(format));
{$ENDIF NO_ANSI_SUPPORT }
    //
    flags := flags and not LOCALE_NOUSEROVERRIDE;
  end;
  //
{$IFNDEF NO_ANSI_SUPPORT }
  if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
    res := GetTimeFormatW(locale, flags, time, fmtW, bufW, sizeOf(bufW) div sizeOf(bufW[1]))
{$IFNDEF NO_ANSI_SUPPORT }
  else
    res := GetTimeFormatA(locale, flags, time, fmtA, bufA, sizeOf(bufA));
{$ENDIF NO_ANSI_SUPPORT }
  ;
  //
  if (0 <> res) then begin
    //
{$IFNDEF NO_ANSI_SUPPORT }
    if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
      result := bufW
{$IFNDEF NO_ANSI_SUPPORT }
    else
      result := wString(bufA);
{$ENDIF NO_ANSI_SUPPORT }
    ;
    //
  end
  else
    result := '';
end;

// --  --
function sysDate2str(date: pSYSTEMTIME; const format: wString; locale: LCID; flags: DWORD): wString;
var
{$IFNDEF NO_ANSI_SUPPORT }
  bufA: array[0..1024] of aChar;
{$ENDIF NO_ANSI_SUPPORT }
  bufW: array[0..1024] of wChar;
  //
{$IFNDEF NO_ANSI_SUPPORT }
  fmtA: paChar;
{$ENDIF NO_ANSI_SUPPORT }
  fmtW: pwChar;
  //
  res: int;
begin
  if ('' = format) then begin
    //
    fmtW := nil;
{$IFNDEF NO_ANSI_SUPPORT }
    fmtA := nil;
{$ENDIF NO_ANSI_SUPPORT }
  end
  else begin
    //
    fmtW := pwChar(format);
{$IFNDEF NO_ANSI_SUPPORT }
    fmtA := paChar(aString(format));
{$ENDIF NO_ANSI_SUPPORT }
  end;
  //
{$IFNDEF NO_ANSI_SUPPORT }
  if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
    res := GetDateFormatW(locale, flags, date, fmtW, bufW, sizeOf(bufW) div sizeOf(bufW[1]))
{$IFNDEF NO_ANSI_SUPPORT }
  else
    res := GetDateFormatA(locale, flags, date, fmtA, bufA, sizeOf(bufA));
{$ENDIF NO_ANSI_SUPPORT }
  ;
  //
  if (0 <> res) then begin
    //
{$IFNDEF NO_ANSI_SUPPORT }
    if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
      result := bufW
{$IFNDEF NO_ANSI_SUPPORT }
    else
      result := wString(bufA)
{$ENDIF NO_ANSI_SUPPORT }
    ;
  end
  else
    result := '';
end;

// --  --
function sysDateTime2localDateTime(const sysDate: SYSTEMTIME; out localDate: SYSTEMTIME): bool;
var
  ft: FILETIME;
  lft: FILETIME;
begin
  result := SystemTimeToFileTime(sysDate, ft);
  result := result and FileTimeToLocalFileTime(ft, lft);
  result := result and FileTimeToSystemTime(lft, localDate);
end;

(*

// --  --
function shiftST(var dateTime: SYSTEMTIME; dseconds: int): bool;
var
  dd,
  dh,
  dm,
  ds: int;
begin
  dd := abs(dseconds) div (24 * 60 * 60);
  dh := abs(dseconds) div (60 * 60);
  dm := abs(dseconds) div (60);
  ds := abs(dseconds) - ((dd * 24 * 60 * 60) + (dh * 60 * 60) + (dm * 60));
  //
  with (dateTime) do begin
    //
    // to do
    if (0 < ds) then ;
  end;
  //
  result := false;
end;

*)

// --  --
function nowUTC(): SYSTEMTIME;
begin
  GetSystemTime(result);
end;

// --  --
function utc2local(const dateTime: SYSTEMTIME): SYSTEMTIME;
begin
  if (not SystemTimeToTzSpecificLocalTime(nil, SYSTEMTIME((@dateTime)^), result)) then
    //
    // since we cannot report an error, return same time at least
    result := dateTime;
end;

// --  --
function monthsPassed(const now, than: SYSTEMTIME): int;
begin
  if (than.wYear < now.wYear - 1) then
    result := (now.wYear - than.wYear - 1) * 12
  else
    result := (now.wYear - than.wYear) * 12;
  //
  if (than.wYear < now.wYear - 1) then
    inc(result, 13 - than.wMonth)
  else
    dec(result, than.wMonth - 1);
  //
  if (1 < now.wMonth) then
    inc(result, now.wMonth - 1);
  //
  if (than.wDay > now.wDay) then
    dec(result)
  else begin
    //
    if (than.wDay = now.wDay) then begin
      //
      if (than.wHour * 60 * 60 + than.wMinute * 60 + than.wSecond >
	   now.wHour * 60 * 60 +  now.wMinute * 60 +  now.wSecond) then begin
	//
	dec(result);
      end;
    end;  
  end;
  //
  if (0 > result) then
    result := - monthsPassed(than, now);
end;

{$IFDEF __SYSUTILS_H_ }
{$ELSE }

// --  --
function isLeapYear(y: int): boolean;
begin
  result := (0 = (y and 3)) and ((0 <> (y mod 100)) or (0 = (y mod 400)));
end;

{$ENDIF __SYSUTILS_H_ }

// --  --
function percent(value, total: unsigned): unsigned;
begin
  if ((0 < total) and (0 < value)) then
    result := round((int64(value) * 100) / total)
  else
    result := 0;
end;

// --  --
function percent(value, total: int64): int64;
begin
  if ((0 < total) and (0 < value)) then
    result := round((value * 100) / total)
  else
    result := 0;
end;


// == strings ==


{$IFDEF __BEFORE_D6__ }
  // Delphi 4 and 5 gone ambiguous with wide/ansi strings
  // So we lost some functionality but avoid ambiguousness
{$ELSE }
// --  --
function trimS(const value: string; left, right: bool): string;
var
  s: int;
  l: int;
begin
  if ('' <> value) then begin
    //
    s := 1;
    l := length(value);
    if (left) then begin
      //
      // -- trim left
      while (s < l) do begin
	//
	if (' ' >= value[s]) then
	  inc(s)
	else
	  break;
	//
      end;
    end;
    //
    if (right) then
      //
      // -- trim right
      while (l >= s) do begin
	//
	if (' ' >= value[l]) then
	  dec(l)
	else
	  break;
	//
      end;
    //
    result := copy(value, s, l + 1 - s);
  end
  else
    result := value;
end;
{$ENDIF __BEFORE_D6__ }

{$IFDEF __BEFORE_DC__ }

// --  --
function trimS(const value: wString; left, right: bool): wString;
var
  s: int;
  l: int;
begin
  if ('' <> value) then begin
    //
    s := 1;
    l := length(value);
    if (left) then begin
      //
      // -- trim left
      while (s < l) do begin
	//
	if (' ' >= value[s]) then
	  inc(s)
	else
	  break;
	//
      end;
    end;
    //
    if (right) then
      //
      // -- trim right
      while (l >= s) do begin
	//
	if (' ' >= value[l]) then
	  dec(l)
	else
	  break;
	//
      end;
    //
    result := copy(value, s, l + 1 - s);
  end
  else
    result := value;
end;

{$ELSE }

// --  --
function trimS(const value: aString; left, right: bool): aString;
var
  s: unsigned;
  l: unsigned;
begin
  if ('' <> value) then begin
    //
    s := 1;
    l := length(value);
    if (left) then begin
      //
      // -- trim left
      while (s < l) do begin
	//
	if (' ' >= value[s]) then
	  inc(s)
	else
	  break;
	//
      end;
    end;
    //
    if (right) then
      //
      // -- trim right
      while (l >= s) do begin
	//
	if (' ' >= value[l]) then
	  dec(l)
	else
	  break;
	//
      end;
    //
    result := copy(value, s, l + 1 - s);
  end
  else
    result := value;
end;

{$ENDIF __BEFORE_DC__ }

// --  --
function loCase(value: char): char;
begin
  case (value) of
    'A'..'Z': {$IFDEF __BEFORE_DC__ }result := char(byte(value) or $20){$ELSE }result := char(word(value) or $0020){$ENDIF __BEFORE_DC__ };
    else
      result := value;
  end;
end;

{$IFDEF __BEFORE_DC__ }

// --  --
function loCase(value: wChar): wChar;
begin
  case (value) of
    'A'..'Z': result := wChar(word(value) or $0020);
    else
      result := value;
  end;
end;

{$ELSE }

// --  --
function loCase(value: aChar): aChar; assembler
{
	IN:	EAX = value
	OUT:	EAX = result
}
asm
	cmp	al, 'A'
	jb	@exit

	cmp	al, 'Z'
	ja	@exit

	or	al, 020h
  @exit:
//	mov	result, al
end;

{$ENDIF __BEFORE_DC__ }


// --  --
function upCase(value: char): char;
begin
  case (value) of
    'a'..'z': {$IFDEF __BEFORE_DC__ }result := char(byte(value) and not $20){$ELSE }result := char(word(value) and not $0020){$ENDIF __BEFORE_DC__ };
    else
      result := value;
  end;
end;


{$IFDEF __BEFORE_DC__ }

// --  --
function upCase(value: wChar): wChar;
begin
  case (value) of
    'a'..'z': result := wChar(word(value) and not $0020);
    else
      result := value;
  end;
end;

{$ELSE }

// --  --
function upCase(value: aChar): aChar;
{
	IN:	EAX = value
	OUT:	EAX = result
}
asm
//	mov	al, value
	cmp	al, 'a'
	jb	@exit

	cmp	al, 'z'
	ja	@exit

	sub	al, 020h
  @exit:
//	mov	result, al
end;

{$ENDIF __BEFORE_DC__ }


{$IFDEF __SYSUTILS_H_ }
{$ELSE }

// --  --
function upperCase(const value: string): string;
var
  i: int;
begin
  setLength(result, length(value));
  //
  for i := 1 to length(value) do
    result[i] := unaUtils.upCase(value[i]);
end;

// --  --
function lowerCase(const value: string): string;
var
  i: int;
begin
  setLength(result, length(value));
  //
  for i := 1 to length(value) do
    result[i] := loCase(value[i]);
end;

{$ENDIF __SYSUTILS_H_ }

{$IFDEF __BEFORE_DC__ }

{$IFDEF __BEFORE_D6__ }
{$ELSE }

// --  --
function lowerCase(const value: wString): wString;
begin
  if ('' <> value) then begin
    //
{$IFNDEF NO_ANSI_SUPPORT }
    if (g_wideApiSupported) then begin
{$ENDIF NO_ANSI_SUPPORT }
      //
      result := value;
      CharLowerW(pwChar(result));	// from MSDN: There is no indication of success or failure. Failure is rare.
					// There is no extended error information for this function; do not call GetLastError.
{$IFNDEF NO_ANSI_SUPPORT }
    end
    else
      result := lowerCase(aString(value));
{$ENDIF NO_ANSI_SUPPORT }
  end
  else
    result := '';
end;

{$ENDIF __BEFORE_D6__ }

{$ELSE }	// __BEFORE_DC__

// --  --
function lowerCase(const value: aString): aString;
begin
  if ('' <> value) then begin
    //
    result := value;
    CharLowerA(paChar(result));
  end
  else
    result := '';
end;

{$ENDIF __BEFORE_DC__ }


{$IFDEF __BEFORE_DC__ }

{$IFDEF __BEFORE_D6__ }
{$ELSE }

// --  --
function upperCase(const value: wString): wString;
begin
  if ('' <> value) then begin
    //
{$IFNDEF NO_ANSI_SUPPORT }
    if (g_wideApiSupported) then begin
{$ENDIF NO_ANSI_SUPPORT }
      //
      result := value;
      CharUpperW(pwChar(result));	// from MSDN: There is no indication of success or failure. Failure is rare.
					// There is no extended error information for this function; do not call GetLastError.
{$IFNDEF NO_ANSI_SUPPORT }
    end
    else
      result := upperCase(aString(value));
{$ENDIF NO_ANSI_SUPPORT }
  end
  else
    result := '';
end;

{$ENDIF __BEFORE_D6__ }
{$ELSE }

// --  --
function upperCase(const value: aString): aString;
begin
  if ('' <> value) then begin
    //
    result := value;
    CharUpperA(paChar(result));
  end
  else
    result := '';
end;

{$ENDIF __BEFORE_DC__ }

{$IFDEF __BEFORE_D6__ }
{$ELSE }

// --  --
function sameString(const str1, str2: string; doTrim: bool): bool;
begin
  if (doTrim) then
    result := (lowerCase(trimS(str1)) = lowerCase(trimS(str2)))
  else
    result := (lowerCase(str1) = lowerCase(str2));
end;

{$ENDIF __BEFORE_D6__ }

// --  --
function compareStr(const str1, str2: string; ignoreCase: bool): int;
var
  i: unsigned;
  len1, len2: unsigned;
  c1, c2: char;
begin
  len1 := length(str1);
  len2 := length(str2);
  //
  if (len1 < len2) then
    result := -1
  else begin
    //
    if (len1 > len2) then
      result := +1
    else begin
      i := 1;
      result := 0;
      while (i < len1) do begin
	//
	c1 := str1[i];
	c2 := str2[i];
	if (ignoreCase) then begin
          //
	  c1 := loCase(c1);
	  c2 := loCase(c2);
	end;
	//
	if (c1 < c2) then begin
          //
	  result := -1;
	  break;
	end
	else begin
          //
	  if (c1 > c2) then begin
            //
	    result := +1;
	    break;
	  end;
        end;
	//
	inc(i);
      end;
    end;
  end;
end;


{$IFDEF __BEFORE_DC__ }

{$IFDEF __BEFORE_D6__ }
{$ELSE }

// --  --
function compareStr(const str1, str2: wString; ignoreCase: bool): int;
var
  i: unsigned;
  len1, len2: unsigned;
  c1, c2: wChar;
begin
  len1 := length(str1);
  len2 := length(str2);
  //
  if (len1 < len2) then
    result := -1
  else begin
    //
    if (len1 > len2) then
      result := +1
    else begin
      i := 1;
      result := 0;
      while (i < len1) do begin
	//
	c1 := str1[i];
	c2 := str2[i];
	if (ignoreCase) then begin
          //
	  c1 := loCase(c1);
	  c2 := loCase(c2);
	end;
	//
	if (c1 < c2) then begin
          //
	  result := -1;
	  break;
	end
	else begin
          //
	  if (c1 > c2) then begin
            //
	    result := +1;
	    break;
	  end;
        end;
	//
	inc(i);
      end;
    end;
  end;
end;

{$ENDIF __BEFORE_D6__ }

{$ELSE }

// --  --
function compareStr(const str1, str2: aString; ignoreCase: bool): int;
var
  i: unsigned;
  len1, len2: unsigned;
  c1, c2: aChar;
begin
  len1 := length(str1);
  len2 := length(str2);
  //
  if (len1 < len2) then
    result := -1
  else begin
    //
    if (len1 > len2) then
      result := +1
    else begin
      i := 1;
      result := 0;
      while (i < len1) do begin
	//
	c1 := str1[i];
	c2 := str2[i];
	if (ignoreCase) then begin
          //
	  c1 := loCase(c1);
	  c2 := loCase(c2);
	end;
	//
	if (c1 < c2) then begin
          //
	  result := -1;
	  break;
	end
	else begin
          //
	  if (c1 > c2) then begin
            //
	    result := +1;
	    break;
	  end;
        end;
	//
	inc(i);
      end;
    end;
  end;
end;

{$ENDIF __BEFORE_DC__ }


//
//  A language ID is a 16 bit value which is the combination of a
//  primary language ID and a secondary language ID.  The bits are
//  allocated as follows:
//
//       +-----------------------+-------------------------+
//       |     Sublanguage ID    |   Primary Language ID   |
//       +-----------------------+-------------------------+
//        15                   10 9                       0   bit
//
//
//  Language ID creation/extraction macros:
//
//    MAKELANGID    - construct language id from a primary language id and
//                    a sublanguage id.
//    PRIMARYLANGID - extract primary language id from a language id.
//    SUBLANGID     - extract sublanguage id from a language id.
//

// --  --
function MAKELANGID(p, s: byte): word;
begin
  result := word(p) or (word(s) shl 10)
end;


//
//  A locale ID is a 32 bit value which is the combination of a
//  language ID, a sort ID, and a reserved area.  The bits are
//  allocated as follows:
//
//       +-------------+---------+-------------------------+
//       |   Reserved  | Sort ID |      Language ID        |
//       +-------------+---------+-------------------------+
//        31         20 19     16 15                      0   bit
//
//
//  Locale ID creation/extraction macros:
//
//    MAKELCID            - construct the locale id from a language id and a sort id.
//    MAKESORTLCID        - construct the locale id from a language id, sort id, and sort version.
//    LANGIDFROMLCID      - extract the language id from a locale id.
//    SORTIDFROMLCID      - extract the sort id from a locale id.
//    SORTVERSIONFROMLCID - extract the sort version from a locale id.
//

// -- --
function MAKELCID(langId, sortId: word): DWORD;
begin
  result := uint32(langId) or ((uint32(sortId) and $0F) shl 16);
end;

{$IFDEF __BEFORE_DC__ }

// --  --
function sameString(const str1, str2: wString; doTrim: bool; locale: LCID): bool;
var
  s1, s2: wString;
  l1, l2: int;
  res: int;
begin
  if (doTrim) then begin
    //
    s1 := unaUtils.trimS(str1);
    s2 := unaUtils.trimS(str2);
  end
  else begin
    //
    s1 := str1;
    s2 := str2;
  end;
  //
  l1 := length(s1);
  l2 := length(s2);
  //
  if ((l1 = l2) and (0 < l1)) then begin
    //
{$IFNDEF NO_ANSI_SUPPORT }
    if (g_wideApiSupported) then begin
{$ENDIF NO_ANSI_SUPPORT }
      //
      if (LOCALE_SYSTEM_DEFAULT = locale) then
	locale := MAKELCID(MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_US), SORT_DEFAULT);
      //
      res := CompareStringW(locale, NORM_IGNORECASE, pwChar(s1), l1, pwChar(s2), l2);
      case (res) of

	CSTR_EQUAL:
	  result := true;

	CSTR_LESS_THAN,
	CSTR_GREATER_THAN:
	  result := false;

	else
	  // give up, compare as dummy strings
	  result := (lowerCase(s1) = lowerCase(s2));

      end;
{$IFNDEF NO_ANSI_SUPPORT }
    end
    else
      result := (lowerCase(s1) = lowerCase(s2));
{$ENDIF NO_ANSI_SUPPORT }
    //
  end
  else
    result := (1 > l1) and (1 > l2);	// same only if both are empty
end;

{$ELSE }

function sameString(const str1, str2: aString; doTrim: bool): bool;
begin
  if (doTrim) then
    result := (lowerCase(trimS(str1)) = lowerCase(trimS(str2)))
  else
    result := (lowerCase(str1) = lowerCase(str2));
end;

{$ENDIF __BEFORE_DC__ }


// --  --
function adjust(const value: string; len: int; fill: char; left: bool; truncate: bool): string;
begin
  len := abs(len);
  //
  // check if we need to add some chars
  if (length(value) < len) then begin
    //
    if (left) then
      // add filling at left
      result := padChar(fill, len - length(value)) + value
    else
      // add filling at right
      result := value + padChar(fill, len - length(value));
  end
  else
    // nothing to adjust
    result := value;
  //
  // check if we need to truncate the result
  if (truncate and (length(result) > len)) then begin
    //
    if (left) then
      // cut from the left
      result := copy(result, length(result) - len + 1, length(result))
    else
      // cut from the right
      result := copy(result, 1, len);
  end;
end;

{$IFDEF __BEFORE_DC__ }

// --  --
function adjust(const value: wString; len: int; fill: wChar; left: bool; truncate: bool): wString;
begin
  len := abs(len);
  //
  // check if we need to add some chars
  if (length(value) < len) then begin
    //
    if (left) then
      // add filling at left
      result := padChar(fill, len - length(value)) + value
    else
      // add filling at right
      result := value + padChar(fill, len - length(value));
  end
  else
    // nothing to adjust
    result := value;
  //
  // check if we need to truncate the result
  if (truncate and (length(result) > len)) then begin
    //
    if (left) then
      // cut from the left
      result := copy(result, length(result) - len + 1, length(result))
    else
      // cut from the right
      result := copy(result, 1, len);
  end;
end;

{$ELSE }

// --  --
function adjust(const value: aString; len: int; fill: aChar; left: bool; truncate: bool): aString;
begin
  len := abs(len);
  //
  // check if we need to add some chars
  if (length(value) < len) then begin
    //
    if (left) then
      // add filling at left
      result := padChar(fill, len - length(value)) + value
    else
      // add filling at right
      result := value + padChar(fill, len - length(value));
  end
  else
    // nothing to adjust
    result := value;
  //
  // check if we need to truncate the result
  if (truncate and (length(result) > len)) then begin
    //
    if (left) then
      // cut from the left
      result := copy(result, length(result) - len + 1, length(result))
    else
      // cut from the right
      result := copy(result, 1, len);
  end;
end;

{$ENDIF __BEFORE_DC__ }

// --  --
function padChar(pad: char; len: unsigned): string;
var
  i: int;
begin
  setLength(result, len);
  //
  for i := 1 to len do
    result[i] := pad;
end;

{$IFDEF __BEFORE_DC__ }

// --  --
function padChar(pad: wChar; len: unsigned): wString;
var
  i: int;
begin
  setLength(result, len);
  //
  for i := 1 to len do
    result[i] := pad;
end;

{$ELSE }

// --  --
function padChar(pad: aChar; len: unsigned): aString;
begin
  setLength(result, len);
  //
  if (0 < len) then
    fillChar(result[1], len, pad);
end;

{$ENDIF __BEFORE_DC__ }

// --  --
function strCopy(dest, source: pChar; maxLen: int): pChar;
begin
  result := dest;
  if ((nil <> dest) and (nil <> source)) then begin
    //
    if (0 > maxLen) then
      maxLen := length(source);
    //
    while ((0 < maxLen) and (#0 <> source^)) do begin
      //
      dest^ := source^;
      inc(dest);
      inc(source);
      dec(maxLen);
    end;
    //
    if (#0 = source^) then
      dest^ := #0;
  end;
end;


{$IFDEF __BEFORE_DC__ }

// --  --
function strCopy(dest, source: pwChar; maxLen: int): pwChar;
begin
  result := dest;
  if ((nil <> dest) and (nil <> source)) then begin
    //
    if (0 > maxLen) then
      maxLen := length(source);
    //
    while ((0 < maxLen) and (#0 <> source^)) do begin
      //
      dest^ := source^;
      inc(dest);
      inc(source);
      dec(maxLen);
    end;
    //
    if (#0 = source^) then
      dest^ := #0;
  end;
end;

{$ELSE }

// --  --
function strCopy(dest, source: paChar; maxLen: int): paChar; assembler;
asm
        //
        // EAX = dest
        // EDX = source
        // ECX = maxLen
        //
	PUSH    EDI
	PUSH    ESI
	PUSH    EBX

	MOV     ESI, EAX        // dest
	MOV     EDI, EDX        // source
	MOV     EBX, ECX        // maxLen
	XOR     AL, AL          // look for #0

        cmp     ecx, -1
        jne     @@0

        mov     ecx, 16384      // some sane string size

@@0:
	TEST    ECX, ECX        // maxLen = 0?
	JZ      @@1

	REPNE   SCASB           // scan ES:EDI (source) for #0
	JNE     @@1             // not found?

	INC     ECX             //

@@1:    SUB     EBX, ECX        // maxLen := min(maxLen, length(source));
	MOV     EDI, ESI
	MOV     ESI, EDX
	MOV     EDX, EDI
	MOV     ECX, EBX
	SHR     ECX, 2
	REP     MOVSD

	MOV     ECX, EBX
	AND     ECX, 3
	REP     MOVSB

	STOSB                   // move terminating #0

	MOV     EAX, EDX

	POP     EBX
	POP     ESI
	POP     EDI
end;


{$ENDIF __BEFORE_DC__ }


// --  --
function strCopy(dest: pChar; const source: string; maxLen: int): pChar;
begin
  result := strCopy(dest, pChar(source), maxLen);
end;


{$IFDEF __BEFORE_DC__ }

// --  --
function strCopy(dest: pwChar; const source: wString; maxLen: int): pwChar;
begin
  result := strCopy(dest, pwChar(source), maxLen);
end;

{$ELSE }

// --  --
function strCopy(dest: paChar; const source: aString; maxLen: int): paChar;
begin
  result := strCopy(dest, paChar(source), maxLen);
end;

{$ENDIF __BEFORE_DC__ }


// --  --
function strNew(const source: string): pChar;
var
  len: int;
begin
  len := length(source);
  result := malloc((len + 1) * sizeOf(source[1]));
  //
  strCopy(result, source, len);
end;

{$IFDEF __BEFORE_DC__ }

// --  --
{$IFDEF __BEFORE_D6__ }
function strNewW(const source: wString): pwChar;
{$ELSE }
function strNew(const source: wString): pwChar;
{$ENDIF __BEFORE_D6__ }
var
  len: int;
begin
  len := length(source) shl 1;
  result := malloc(len + 2);
  //
  strCopy(result, source, len shr 1);
end;

{$ELSE }

// --  --
function strNew(const source: aString): paChar;
var
  len: int;
begin
  len := length(source);
  result := malloc(len + 1);
  //
  strCopy(result, source, len);
end;

{$ENDIF __BEFORE_DC__ }


// --  --
function strNewA(str: paChar): paChar;
var
  size: unsigned;
begin
  if (nil = str) then
    result := nil
  else begin
    //
    size := strLenA(str) + 1;
    result := strAllocA(size);
    move(str^, result^, size);
  end;
end;

// --  --
function str2array(const src: string; var A: array of char): int;
var
  l: int;
begin
  l := low(A);
  result := min(high(A) - l, length(src));
  if (0 < result) then begin
    //
    move(src[1], A[l], result * sizeOf(src[1]));
    A[l + result] := #0;
  end
  else
    A[l] := #0;
end;


{$IFDEF __BEFORE_DC__ }

// --  --
{$IFDEF __BEFORE_D6__ }
function str2arrayW(const src: wString; var A: array of wChar): int;
{$ELSE }
function str2array(const src: wString; var A: array of wChar): int;
{$ENDIF __BEFORE_D6__ }
var
  l: int;
begin
  l := low(A);
  result := min(high(A) - l, length(src));
  if (0 < result) then begin
    //
    move(src[1], A[l], result * sizeOf(src[1]));
    A[l + result] := #0;
  end
  else
    A[l] := #0;
end;

{$ELSE }

// --  --
function str2array(const src: aString; var A: array of aChar): int;
var
  l: int;
begin
  l := low(A);
  result := min(high(A) - l, length(src));
  if (0 < result) then begin
    //
    move(src[1], A[l], result * sizeOf(src[1]));
    A[l + result] := #0;
  end
  else
    A[l] := #0;
end;

{$ENDIF __BEFORE_DC__ }


// --  --
function array2str(const A: array of char; out value: string; startPos, length: int): int;
var
  sz: int;
  maxArrayLengthBytes: int;
begin
  if (low(int) = startPos) then
    startPos := low(A)
  else
    startPos := max(low(A), startPos);
  //
  sz := sizeOf(A[low(A)]);
  if (0 > length) then
    length := (high(A) - startPos) * sz
  else
    length := min(length, (high(A) - startPos) * sz);
  //
  result := length div sz;		//
  maxArrayLengthBytes := length * sz;	//
  //
  if (0 < result) then begin
    //
    setLength(value, result);
    move(A[startPos], value[1], maxArrayLengthBytes);
  end
  else
    value := '';
end;


{$IFDEF __BEFORE_DC__ }

// --  --
function array2str(const A: array of wChar; out value: wString; startPos, length: int): int;
var
  sz: int;
  maxArrayLengthBytes: int;
begin
  if (low(int) = startPos) then
    startPos := low(A)
  else
    startPos := max(low(A), startPos);
  //
  sz := sizeOf(A[low(A)]);
  if (0 > length) then
    length := (high(A) - startPos) * sz
  else
    length := min(length, (high(A) - startPos) * sz);
  //
  result := length div sz;		//
  maxArrayLengthBytes := length * sz;	//
  //
  if (0 < result) then begin
    //
    setLength(value, result);
    move(A[startPos], value[1], maxArrayLengthBytes);
  end
  else
    value := '';
end;

{$ELSE }

// --  --
function array2str(const A: array of aChar; out value: aString; startPos, length: int): int;
var
  sz: int;
  maxArrayLengthBytes: int;
begin
  if (low(int) = startPos) then
    startPos := low(A)
  else
    startPos := max(low(A), startPos);
  //
  sz := sizeOf(A[low(A)]);
  if (0 > length) then
    length := (high(A) - startPos) * sz
  else
    length := min(length, (high(A) - startPos) * sz);
  //
  result := length div sz;		//
  maxArrayLengthBytes := length * sz;	//
  //
  if (0 < result) then begin
    //
    setLength(value, result);
    move(A[startPos], value[1], maxArrayLengthBytes);
  end
  else
    value := '';
end;

{$ENDIF __BEFORE_DC__ }


// --  --
function array2str(const A: array of wChar; out value: wString; maxArrayLength: int): int;
begin
  if (0 > maxArrayLength) then
    maxArrayLength := (high(A) - low(A)) * sizeOf(A[low(A)]);
  //
  result := maxArrayLength div sizeOf(A[low(A)]);	//
  maxArrayLength := (result - 1) * sizeOf(A[low(A)]);	// not including last #0 character
  //
  if (0 < result) then begin
    //
    setLength(value, result);
    move(A[low(A)], value[1], maxArrayLength);
    value[result] := #0;
  end
  else
    value := '';
end;


// --  --
function strLenA(str: paChar): unsigned; assembler;
asm
  // IN:	EAX = str
  // OUT:	EAX = result
	MOV     EDX,EDI
	MOV     EDI,EAX
	MOV     ECX,0FFFFFFFFH
	XOR     AL,AL
	REPNE   SCASB
	MOV     EAX,0FFFFFFFEH
	SUB     EAX,ECX
	MOV     EDI,EDX
end;

// --  --
function strAllocA(size: uint): paChar;
begin
  result := malloc(size);
end;

// --  --
function strDisposeA(str: paChar): bool;
begin
  mrealloc(str);
  result := true;
end;

// --  --
function strDisposeW(str: pwChar): bool;
begin
  mrealloc(str);
  result := true;
end;  

// --  --
function strScanA(const str: paChar; chr: aChar): paChar; assembler;
asm
	PUSH    EDI
	PUSH    EAX
	MOV     EDI, str
	MOV     ECX, 0FFFFFFFFH
	XOR     AL, AL
	REPNE   SCASB
	NOT     ECX
	POP     EDI
	MOV     AL, chr
	REPNE   SCASB
	MOV     EAX, 0
	JNE     @@1
	MOV     EAX, EDI
	DEC     EAX
@@1:    POP     EDI
end;

// --  --
function strPosA(const strSource, strToFind: paChar): paChar; assembler;
asm
	PUSH    EDI
	PUSH    ESI
	PUSH    EBX
	OR      EAX,EAX
	JE      @@2
	OR      EDX,EDX
	JE      @@2
	MOV     EBX,EAX
	MOV     EDI,EDX
	XOR     AL,AL
	MOV     ECX,0FFFFFFFFH
	REPNE   SCASB
	NOT     ECX
	DEC     ECX
	JE      @@2
	MOV     ESI,ECX
	MOV     EDI,EBX
	MOV     ECX,0FFFFFFFFH
	REPNE   SCASB
	NOT     ECX
	SUB     ECX,ESI
	JBE     @@2
	MOV     EDI,EBX
        {$IFDEF FPC }
	LEA     EBX,[{$IFDEF CPU64 }RSI-1{$ELSE }ESI-1{$ENDIF CPU64 }]
	{$ELSE }
	LEA     EBX,[ESI-1]
        {$ENDIF FPC }
@@1:    MOV     ESI,EDX
	LODSB
	REPNE   SCASB
	JNE     @@2
	MOV     EAX,ECX
	PUSH    EDI
	MOV     ECX,EBX
	REPE    CMPSB
	POP     EDI
	MOV     ECX,EAX
	JNE     @@1
        {$IFDEF FPC }
	LEA     EAX,[{$IFDEF CPU64 }RDI-1{$ELSE }EDI-1{$ENDIF CPU64 }]
	{$ELSE }
	LEA     EAX,[EDI-1]
        {$ENDIF FPC }
	JMP     @@3
@@2:    XOR     EAX,EAX
@@3:    POP     EBX
	POP     ESI
	POP     EDI
end;

// --  --
function lastDelimiter(const delimiters, s: wString): int;
begin
  result := length(s);
  while (0 < result) do begin
    //
    if ((#0 <> s[result]) and (0 < pos(s[result], delimiters))) then
      break;
    //
    dec(result);
  end;
end;


const
  escapeChar = '/';

// --  --
function strEscape(const value, specialCare: aString): aString;
var
  s: int;
  p: int;
  len: int;

  procedure add(const subStr: aString);
  begin
    if (p > s) then
      result := result + copy(value, s, p - s) + subStr
    else
      result := result + subStr;
    //
    s := p + 1;
  end;

  function tri(): aString;
  begin
    result := aString(adjust(int2str(byte(value[p])), 3, '0'));
  end;

begin
  s := 1;
  p := 1;
  result := '';
  len := length(value);
  while (p <= len) do begin
    //
    case(value[p]) of

      #13: add(escapeChar + 'r');
      #10: add(escapeChar + 'n');
      #9:  add(escapeChar + 't');
      escapeChar: add(escapeChar + escapeChar);
      else
	if (0 < pos(value[p], specialCare)) then
	  add(escapeChar + tri())
	else
	  case (value[p]) of
	    #0..#31,
	    #127..#255: add(escapeChar + tri());
	    else
	      // just skip to next char
	  end;
    end;
    //
    inc(p);
  end;
  add('');
end;

// --  --
function strUnescape(const value: aString): aString;
var
  s: int;
  p: int;
  len: int;

  procedure add(const subStr: aString);
  begin
    if (p > s) then
      result := result + copy(value, s, p - s) + subStr
    else
      result := result + subStr;
    //
    s := p;
  end;

var
  prefix: bool;
  val: aString;
  d: int;
begin
  s := 1;
  p := 1;
  result := '';
  len := length(value);
  prefix := false;
  //
  while (p <= len) do begin
    //
    if (prefix) then begin
      //
      d := 0;
      case (value[p]) of

	'r': add(#13);

	'n': add(#10);

	't': add(#9);

	'0'..'2': begin
          //
	  val := copy(value, p, 3);
	  inc(p, 2);
	  s := p + 1;
	  add(aChar(str2IntByte(string(val), 0)));
	end;

	else
	  d := -1;

      end;
      //
      s := int(p) + 1 + d;
      prefix := false;
    end
    else
      case(value[p]) of

	escapeChar: begin
	  //
	  add('');
	  prefix := true;
	  s := p + 1;
	end

	else
	  prefix := false;
	  // just skip to next char
      end;
    //
    inc(p);
  end;
  //
  add('');
end;

// --  --
function htmlEscape(const value: aString; strict: bool): aString;
var
  len: integer;
  pos: integer;
begin
  len := length(value);
  pos := 1;
  result := '';
  //
  while (pos <= len) do begin
    //
    case (value[pos]) of

      #0..#3: 	;	// nothing

      #4: result := result + '<'; 	// hack
      #5: result := result + '>';	// hack
      #6: result := result + '&';	// hack

      #7..#9: 	;	// nothing

      #10: begin
	result := result + '<BR>';	// new line
      end;

      #11..#31: ;	// nothing

      #032..#127,
      #165, #168, #170, #175,	//
      #178, #179, #180, #184,
      #186, #191, #192 .. #255: begin
	//
	case (value[pos]) of

	  '&': result := result + '&amp;';
	  '<': result := result + '&lt;';
	  '>': result := result + '&gt;';

	  else
	    result := result + value[pos];

	end;
      end;

      else begin
	//
	if (strict) then
	  result := result + '&#x' + aString(int2str(ord(value[pos]), 16)) + ';'
	else
	  result := result + value[pos];
	//
      end;

    end;
    //
    inc(pos);
  end;
end;

// --  --
function urlEncode(const value: aString): aString;
var
  i: int;
begin
  result := '';
  //
  for i := 1 to length(value) do begin
    //
    case (value[i]) of

      'a'..'z',
      'A'..'Z',
      '0'..'9',
      '$', '-', '_', '@', '.', '&', ':', ',', '\', '/': result := result + value[i];

      else
	result := result + '%' + aString(int2str(ord(value[i]), 16));

    end;
  end;  
end;

// --  --
function urlDecode(const value: aString): aString;
var
  i: int;
begin
  result := '';
  //
  i := 1;
  while (i <= length(value)) do begin
    //
    case (value[i]) of

      '%': begin
        //
	result := result + aChar(str2intInt(copy(string(value), i + 1, 2), 32, 16));
	inc(i, 2);
      end;

      '+':
	result := result + ' ';

      else
	result := result + value[i];

    end;
    //
    inc(i);
  end;
end;

// --  --
function formatTemplate(const templ: aString; const vars: aString; unescapeVars: bool): aString;
var
  s: int;
  p: int;
  len: int;

  // --  --
  procedure add(const subStr: aString);
  begin
    if (p > s) then
      result := result + copy(templ, s, p - s) + subStr
    else
      result := result + subStr;
    //
    s := p;
  end;

var
  vname: aString;
  vmode: bool;
  vlen: int;
  i: int;
  vs: int;
  uVars: aString;
begin
  result := '';
  s := 1;
  p := 1;
  len := length(templ);
  vlen := length(vars);
  vmode := false;
  vname := '';
  uVars := aString(upperCase(string(vars)));
  //
  while (p <= len) do begin
    //
    if (vmode) then begin
      //
      if ('%' = templ[p]) then begin
	//
	s := p + 1;
	if ('' = vname) then begin
	  //
	  add('%');
	end
	else begin
	  //
	  vname := aString(upperCase(string(vname)) + #9);
	  //
	  i := pos(vname, uVars);
	  //
	  if (1 <= i) then begin
	    // skip variable name
	    inc(i, length(vname) - 1);
	    //
	    // skip all until #9
	    while ((i <= vlen) and (#9 <> vars[i])) do
	      inc(i);
	    //
	    // vs is the beginning position of a value
	    vs := i + 1;
	    //
	    // locate the end of value
	    while ((i <= vlen) and (#10 <> vars[i])) do
	      inc(i);
	    //
	    if (i > vs) then begin
	      //
	      if (unescapeVars) then
		add(strUnescape(copy(vars, vs, i - vs)))
	      else
		add(copy(vars, vs, i - vs));
	    end;	
	    //
	  end;
	end;
	//
	s := p + 1;
	vmode := false;
      end
      else
	vname := vname + templ[p];
    end
    else begin
      //
      if ('%' = templ[p]) then begin
	//
	add('');
	vmode := true;
	vname := '';
      end;
    end;  
    //
    inc(p);
  end;
  //
  add('');
end;

// --  --
function nextToken(const text: wString; var startPos: int): wString;
var
  len: int;
  pos: int;
  lastChar: wChar;
  complete: bool;
  mode: unsigned;
  c: wChar;
begin
  len := length(text);
  pos := startPos;
  mode := 0;
  lastChar := ' ';
  complete := false;
  //
  while (pos <= len) do begin
    //
    c := text[pos];
    case (mode) of

      0:
	case (c) of

	  #00..#32:
	    inc(startPos);	// skip delimiters

	  else begin
	    dec(pos);
	    mode := 1;
	  end;
	end;

      1:
	case (c) of

	  #00..#32:	// stop
	    break;

	  '"', '''': begin
	    //
	    if (startPos = pos) then begin
	      //
	      lastChar := c;
	      mode := 2;
	    end;
	  end;

	  else
	    ;
	end;

      2: begin
	//
	case (c) of

	  '"', '''': begin
	    //
	    if (lastChar = c) then begin
	      //
	      complete := true;
	      break;
	    end;
	  end;

	  else
	    ;
	end;
      end;

    end;
    inc(pos);
  end;
  //

  if (' ' = lastChar) then
    result := copy(text, startPos, pos - startPos)
  else begin
    //
    result := copy(text, startPos + 1, pos - startPos - choice(complete, int(1), 0));
    inc(pos);
  end;
  //
  startPos := pos;
end;


// --  --
function replaceTokens(var text: aString; const tokens: aString): int;
var
  noCareSelStart: int;
begin
  noCareSelStart := 0;	// no care
  result := replaceTokens(text, tokens, noCareSelStart);
end;

// --  --
function replaceTokens(var text: aString; const tokens: aString; var careSelStart: int): int;
var
  w: wString;
begin
  w := wString(text);
  result := replaceTokens(w, wString(tokens), careSelStart);
  text := aString(w);
end;

// --  --
function replaceTokens(var text: wString; const tokens: wString; var careSelStart: int): int;
var
  maxLen: int;
  res: wString;
  token: wString;
  sep: wString;
  s: int;
  preS: int;
  tokenPos: int;
begin
  maxLen := length(text);
  res := '';
  s := 1;
  result := 0;
  //
  while (s <= maxLen) do begin
    //
    preS := s;
    token := nextToken(text, s);
    //
    if (s > preS) then begin
      // copy separators as is
      sep := copy(text, preS, int(s - preS) - length(token));
      res := res + sep;
    end;
    //
    if (('' <> token) and
	(s <= maxLen){not last token!} and
	(int(s) <> careSelStart + 1){not the one we are editing now!}) then begin
      //
      tokenPos := pos(#10 + string(token) + #9, tokens);
      if (0 < tokenPos) then begin
	// replace token
	inc(tokenPos);
	sep := copy(tokens, tokenPos + length(token) + 1, maxInt);
	delete(sep, pos(#10, sep), maxInt);
	//
	res := res + sep;
	//
	if (careSelStart > int(preS)) then
	  inc(careSelStart, length(sep) - length(token));
	//
	inc(result);
      end
      else
	res := res + token;
    end
    else begin
      // simply add a token (probably the last one)
      res := res + token;
    end;
  end;
  //
  text := res;
end;

// --  --
function getIntValueFromStr(const str, paramName: string; defValue: int): int;
var
  s: int;
  sub: string;
begin
  s := pos(paramName + '=', str);
  if (0 < s) then begin
    //
    sub := copy(str, s + length(paramName) + 1, maxInt);
    s := pos(#9, sub);
    if (0 < s) then
      sub := copy(sub, 1, s - 1);
    //
    result := str2intInt(sub, defValue);
  end
  else
    result := defValue;
end;


// --  --
function ShellAboutA; external 'shell32.dll' name 'ShellAboutA';
function ShellAboutW; external 'shell32.dll' name 'ShellAboutW';

// --  --
function guiAboutBox(const appName, otherStuff: wString; handle: tHandle; icon: hIcon): int;
begin
  if ($FFFFFFFF = icon) then
    icon := LoadIcon(GetModuleHandle(nil), 'MAINICON');
  //
{$IFNDEF NO_ANSI_SUPPORT }
  if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
    result := ShellAboutW(handle, pwChar(appName), pwChar(otherStuff), icon)
{$IFNDEF NO_ANSI_SUPPORT }
  else
    result := ShellAboutA(handle, paChar(aString(appName)), paChar(aString(otherStuff)), icon);
{$ENDIF NO_ANSI_SUPPORT }
  ;
end;

// --  --
function guiMessageBox(owner: hWnd; const message, title: wString; flags: int): int;
begin
  result := guiMessageBox(message, title, flags, owner);
end;

// --  --
function guiMessageBox(const message, title: wString; flags: int; owner: hWnd): int;
begin
{$IFNDEF NO_ANSI_SUPPORT }
  if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
    result := messageBoxW(owner, pwChar(message), pwChar(title), flags)
{$IFNDEF NO_ANSI_SUPPORT }
  else
    result := messageBoxA(owner, paChar(aString(message)), paChar(aString(title)), flags)
{$ENDIF NO_ANSI_SUPPORT }
  ;
end;

// --  --
function getModuleFileNameExt(const ext: wString): wString;
var
  i: int;
{$IFNDEF NO_ANSI_SUPPORT }
  pathA: array[0..MAX_PATH] of aChar;
{$ENDIF NO_ANSI_SUPPORT }
  pathW: array[0..MAX_PATH] of wChar;
begin
{$IFNDEF NO_ANSI_SUPPORT }
  if (g_wideApiSupported) then begin
{$ENDIF NO_ANSI_SUPPORT }
    //
    i := GetModuleFileNameW(0, pathW, MAX_PATH);
    //
    while ((0 < i) and ('.' <> pathW[i])) do
      dec(i);
    //
    pathW[i] := #0;
    result := pathW;
{$IFNDEF NO_ANSI_SUPPORT }
  end
  else begin
    //
    i := GetModuleFileNameA(0, pathA, MAX_PATH);
    //
    while ((0 < i) and ('.' <> pathA[i])) do
      dec(i);
    //
    pathA[i] := #0;
    result := string(pathA);
  end;
{$ENDIF NO_ANSI_SUPPORT }
  //
  if ('' <> ext) then
    result := result + '.' + ext;
end;

// --  --
function getModulePathName(const fileName: wString): wString;
begin
  result := addBackSlash(extractFilePath(getModuleFileNameExt(''))) + fileName;
end;

// --  --
function assertLogMessage(const message: string; logToScreen: int; logToFile: int; logTimeMode: unaInfoMessage_logTimeModeEnum; logMemoryInfo: int; logThreadId: int): bool;
begin
{$IFDEF DEBUG }
  logMessage(message, c_logModeFlags_debug, logToScreen, logToFile, logTimeMode, logMemoryInfo, logThreadId);
  result := true;
{$ELSE }
  result := true;
{$ENDIF DEBUG }
end;


{$IFDEF UNAUTILS_DEBUG_MEM }

const
  c_maxAllocEntries  = 8192 * 4;
var
  g_allocMemSize: int;
  g_allocMemCount: int;
  //
  g_allocMemPtr: array[0..c_maxAllocEntries - 1] of pointer;
  g_allocMemSz : array[0..c_maxAllocEntries - 1] of uint32;
  //
  g_memLock: _RTL_CRITICAL_SECTION;

{$ENDIF UNAUTILS_DEBUG_MEM }

// --  --
function ams(): int;
{$IFDEF __AFTER_D9__ }
  {$IFDEF UNAUTILS_DEBUG_MEM }
  {$ELSE }
  {$IFDEF FPC }
  {$ELSE }
var
  mms: TMemoryManagerState;
  i: int;
  {$ENDIF FPC }
  {$ENDIF UNAUTILS_DEBUG_MEM }
{$ENDIF __AFTER_D9__ }
begin
  {$IFDEF __AFTER_D9__ }	// Delphi 2006 or later
    //
    {$IFDEF FPC }
      result := GetFPCHeapStatus().CurrHeapUsed;
    {$ELSE }
      {$IFDEF UNAUTILS_DEBUG_MEM }
        // a bit faster
        result := g_allocMemSize;
      {$ELSE }
        GetMemoryManagerState(mms);
        result := 0;
        for i := 0 to high(mms.SmallBlockTypeStates) do
          inc(result, mms.SmallBlockTypeStates[i].AllocatedBlockCount * mms.SmallBlockTypeStates[i].UseableBlockSize);
        //
        inc(result, mms.TotalAllocatedMediumBlockSize);
        inc(result, mms.TotalAllocatedLargeBlockSize);
      {$ENDIF UNAUTILS_DEBUG_MEM }
    {$ENDIF FPC }
  {$ELSE }
    result := allocMemSize;
  {$ENDIF __AFTER_D9__ }
end;

{$IFDEF VC25_OVERLAPPED }
  {$I unaUtilsOL.inc }
{$ENDIF VC25_OVERLAPPED }


// --  --
function infoMessage(const message: string; logToScreen: int; logToFile: int; logTimeMode: unaInfoMessage_logTimeModeEnum; logMemoryInfo: int; logThreadId: int; flags: int): bool;

  // --  --
  function getDate(const st: SYSTEMTIME): string;
  begin
    if ((g_infoLogLastDate.wYear <> st.wYear) or (g_infoLogLastDate.wMonth <> st.wMonth) or (g_infoLogLastDate.wDay <> st.wDay)) then begin
      //
      result := int2str(st.wYear) + '.' + adjust(int2str(st.wMonth), 2, '0') + '.' + adjust(int2str(st.wDay), 2, '0') + ' ';
      //
      g_infoLogLastDate := st;
    end
    else
      result := ' ';
  end;

  // --  --
  function getTime(const st: SYSTEMTIME): wString;
  begin
    result := adjust(int2str(st.wHour), 2, '0') + ':' + adjust(int2str(st.wMinute), 2, '0') + ':' + adjust(int2str(st.wSecond), 2, '0') + '.' + adjust(int2str(st.wMilliseconds), 3, '0') + ' ';
  end;

var
  data: wString;
  dataA: aString;
  te: int64;
  st: SYSTEMTIME;
  stdout: tHandle;
begin
  result := false;
  if (g_unaUtilsFinalized) then
    exit;
  //
  if (-1 = logToScreen) then
    logToScreen := g_infoLogToScreen;
  //
  if (-1 = logToFile) then
    logToFile := choice(g_infoLogToFile, int(1), 0);
  //
  if (
       (0 < logToScreen) or
       (assigned(g_infoLogProcedure)) or
       ((1 = logToFile) and (INVALID_HANDLE_VALUE <> g_infoLogFileHandle))
    ) then begin
    //
    if (unaltm_default = logTimeMode) then
      logTimeMode := g_infoLogTimeMode;
    //
    if (-1 = logMemoryInfo) then
      logMemoryInfo := choice(g_infoLogMemoryInfo, int(1), 0);
    //
    if (-1 = logThreadId) then
      logThreadId := choice(g_infoLogThreadId, int(1), 0);
    //
    case (logTimeMode) of

      unaLtm_date,
      unaLtm_time,
      unaLtm_dateTime,
      unaLtm_timeDelta,
      unaLtm_dateTimeDelta,
      unaLtm_dateTimeDelta64: begin
	//
	if (g_infoLogUseSystemTime) then
	  GetSystemTime(st)
	else
	  GetLocalTime(st);
      end;

    end;
    //
    case (logTimeMode) of

      unaLtm_date:      data := getDate(st);
      unaLtm_time:      data := getTime(st);
      unaLtm_dateTime:  data := getDate(st) + getTime(st);

      unaLtm_timeDelta,
      unaLtm_dateTimeDelta,
      unaLtm_dateTimeDelta64: begin
	//
	if ((unaLtm_dateTimeDelta = logTimeMode) or (unaLtm_dateTimeDelta64 = logTimeMode)) then
	  data := getDate(st)
	else
	  data := '';
	//
	if (unaLtm_dateTimeDelta64 = logTimeMode) then
	  te := timeElapsed64(g_infoLogTimeMark)
	else
	  te := timeElapsed32(g_infoLogTimeMark);
	//
	data := data + getTime(st) + '+' + adjust(int2str(te, 10, 3), choice(unaLtm_dateTimeDelta64 = logTimeMode, 12, int(8)), ' ') + ' ';
	g_infoLogTimeMark := timeMark();
      end;

      else
	data := '';

    end;
    //
    if (1 = logMemoryInfo) then
      data := data + adjust(' <' + int2str(ams(), 10, 3) + '>', 12, ' ');
    //
    if (1 = logThreadId) then
      data := data + '[' + adjust(int2str(GetCurrentThreadId(), 16), 5, '0') + '] ';
    //
    data := data + message;
    //
    if (0 < logToScreen) then begin
      //
      stdout := GetStdHandle(DWORD(STD_OUTPUT_HANDLE));
      case (stdout) of

	0,
	INVALID_HANDLE_VALUE:
	  guiMessageBox(data, 'Information message', MB_OK);

	else begin
	  //
	  {$IFDEF CONSOLE }
	  if (2 = logToScreen) then	// do not add CRLF?
	    writeToFile(stdout, aString(data))
	  else
	    writeToFile(stdout, aString(data + #13#10));
	  {$ENDIF CONSOLE }
	  //
	end;
      end;
    end;
    //
    if (assigned(g_infoLogProcedure)) then
      g_infoLogProcedure(data);
    //
    //
    if ((1 = logToFile) and (INVALID_HANDLE_VALUE <> g_infoLogFileHandle)) then begin
      //
      data := data + #13#10;
      if (g_infoLogUseWideStrings) then begin
	//
	{$IFDEF VC25_IOCP }
	if (0 <> (flags and c_logModeFlags_noOL)) then
	{$ENDIF VC25_IOCP }
	  writeToFile(g_infoLogFileNameW + '.nol', @data[1], length(data) * sizeOf(data[1]), 0, 2)
	{$IFDEF VC25_IOCP }
	else
	  write2file(g_infoLogFileHandle, {$IFDEF VC25_OVERLAPPED }g_logOLOffs,{$ENDIF } @data[1], length(data) * sizeOf(data[1]))
	{$ENDIF VC25_IOCP }
      end
      else begin
	//
	dataA := aString(data);
	{$IFDEF VC25_IOCP }
	if (0 <> (flags and c_logModeFlags_noOL)) then
	{$ENDIF VC25_IOCP }
	  writeToFile(g_infoLogFileNameW + '.nol', @dataA[1], length(dataA), 0, 2)
	{$IFDEF VC25_IOCP }
	else
	  write2file(g_infoLogFileHandle, {$IFDEF VC25_OVERLAPPED }g_logOLOffs,{$ENDIF } @dataA[1], length(dataA));
	{$ENDIF VC25_IOCP }
      end;
    end;
    //
    result := true;
  end;
end;

// --  --
function logMessage(const message: string; flags: int; logToScreen: int; logToFile: int; logTimeMode: unaInfoMessage_logTimeModeEnum; logMemoryInfo: int; logThreadId: int): bool;
begin
  if (0 > flags) then
    flags := g_infoLogMessageFlags;
  //
  if (0 <> (flags and g_infoLogMessageFlags)) then
    result := infoMessage(message, logToScreen, logToFile, logTimeMode, logMemoryInfo, logThreadId, flags)
  else
    result := false;
end;

// --  --
function setInfoMessageMode(const logName: wString; proc: infoMessageProc; logToScreen: int; logToFile: int; logTimeMode: unaInfoMessage_logTimeModeEnum; logMemoryInfo: int; logThreadId: int; useWideStrings: bool): wString;
begin
  result := '';
  //
  result := trimS(logName, true);
  if ('' = result) then
    result := getModuleFileNameExt('log')
  else begin
    //
    if ('<NONE>' = upperCase(result)) then
      result := ''
    else
      if ('<>' = result) then
	result := g_infoLogFileNameW;	// no change
  end;
  //
  g_infoLogFileNameW := result;
  if ('' <> g_infoLogFileNameW) then begin
    //
    g_infoLogFileHandle := fileCreate(g_infoLogFileNameW, false, true, {$IFDEF VC25_OVERLAPPED }FILE_FLAG_OVERLAPPED{$ELSE }0{$ENDIF VC25_OVERLAPPED });
    {$IFDEF VC25_OVERLAPPED }
    if (INVALID_HANDLE_VALUE <> g_infoLogFileHandle) then
      g_logOLOffs := fileSize(g_infoLogFileHandle);
    {$ENDIF VC25_OVERLAPPED }
  end;
  //
  if (-1 <> logToFile) then
    g_infoLogToFile := (0 < logToFile);
  //
  if (-1 <> logToScreen) then
    g_infoLogToScreen := logToScreen;
  //
  if (UIntPtr(-1) <> UIntPtr(addr(proc))) then
    g_infoLogProcedure := proc;
  //
  if (unaltm_default <> logTimeMode) then
    g_infoLogTimeMode := logTimeMode;
  //
  if (-1 <> logMemoryInfo) then
    g_infoLogMemoryInfo := (0 < logMemoryInfo);
  //
  if (-1 <> logThreadId) then
    g_infoLogThreadId := (0 < logThreadId);
  //
  g_infoLogUseWideStrings := useWideStrings;
  //
  g_infoLogTimeMark := timeMark();
end;

{$IFDEF DEBUG }

// --  --
function debug_memAllocated(): unsigned;
begin
  result := ams();
  //
  logMessage('allocMemSize: ' + int2str(result, 10, 3));
end;

{$ENDIF DEBUG }

// --  --
function color2rgb(color: int): tRGB;
begin
  if (0 > color) then
    color := GetSysColor(color and $000000FF);
  //
  result.asInt := color;
end;

// --  --
function color2str(color: int): string;
begin
  with (color2rgb(color)) do
    result := 'R:' + adjust(int2str(r), 3, '0') + '; ' +
	      'G:' + adjust(int2str(g), 3, '0') + '; ' +
	      'B:' + adjust(int2str(b), 3, '0');
end;

// --  --
function colorShift(color: int; op: tunaColorOp): int;

  // --  --
  function wearOutComponent(component: byte; amount: byte): byte;
  begin
    case (component) of

      $00..$1F: result := component + amount div 2;
      $20..$5F: result := component + amount div 3;
      $60..$8F: result := component - amount div 3;
      $90..$AF: result := component - amount div 2;

      // $B0..$FF
      else      result := component - amount;

    end;
  end;

var
  rgb: tRGB;
begin
  rgb := color2rgb(color);
  with rgb do begin
    //
    case (op) of

      unaco_wearOut: begin
	//
	r := wearOutComponent(r, 60);
	g := wearOutComponent(g, 60);
	b := wearOutComponent(b, 60);
      end;

    end;
    //
    result := asInt;
  end;
end;


// == registry ==

// --  --
function getRegValue(const path, keyName: aString; var buf; var size: DWORD; rootKey: HKEY): int;
var
  key: HKEY;
begin
  result := RegOpenKeyExA(rootKey, paChar(path), 0{reserved}, KEY_READ, key);
  if (ERROR_SUCCESS = result) then
    try
      result := RegQueryValueExA(key, paChar(keyName), nil{reserved}, nil{OUT: key type}, @buf, @size);
    finally
      RegCloseKey(key);
    end
end;

// --  --
function setRegValue(const path, keyName: aString; const buf; size: DWORD; keyType: int; rootKey: HKEY): long;
var
  key: HKEY;
begin
  result := RegCreateKeyExA(rootKey, paChar(path), 0{reserved}, nil{class, must be NULL}, REG_OPTION_NON_VOLATILE, KEY_WRITE, nil{security}, key, nil);
  if (ERROR_SUCCESS = result) then
    try
      result := RegSetValueExA(key, paChar(keyName), 0{reserved}, DWORD(keyType), pointer(@buf), size);
    finally
      RegCloseKey(key);
    end
end;

// --  --
function getRegValue(const path, keyName: aString; defValue: int; rootKey: HKEY): int;
var
  size: DWORD;
begin
  size := sizeof(result);
  if (ERROR_SUCCESS <> getRegValue(path, keyName, result, size, rootKey)) then
    result := defValue;
end;

// --  --
function getRegValue(const path, keyName: aString; defValue: unsigned; rootKey: HKEY): unsigned;
var
  size: DWORD;
begin
  size := sizeOf(result);
  if (ERROR_SUCCESS <> getRegValue(path, keyName, result, size, rootKey)) then
    result := defValue;
end;

// --  --
function setRegValue(const path, keyName: aString; keyValue: int; rootKey: HKEY): long;
begin
  result := setRegValue(path, keyName, keyValue, sizeOf(keyValue), REG_DWORD, rootKey);
end;

// --  --
function setRegValue(const path, keyName: aString; keyValue: unsigned; rootKey: HKEY): long;
begin
  result := setRegValue(path, keyName, keyValue, sizeOf(keyValue), REG_DWORD, rootKey);
end;

// -- --
function getRegValue(const path, keyName: aString; const defValue: aString; rootKey: HKEY): aString;
var
  size: DWORD;
begin
  size := 0;
  result := '0';
  //
  if (ERROR_MORE_DATA = getRegValue(path, keyName, result[1], size, rootKey)) then begin
    //
    SetLength(result, size - 1);
    if (1 < size) then begin
      //
      if (ERROR_SUCCESS <> getRegValue(path, keyName, result[1], size, rootKey)) then
	result := defValue;
    end
    else
      result := '';
  end
  else
    result := defValue;
end;

// --  --
function setRegValue(const path, keyName: aString; const keyValue: aString; rootKey: HKEY): long;
var
  zero: aChar;
begin
  if ('' <> keyValue) then
    result := setRegValue(path, keyName, keyValue[1], Length(keyValue) + 1, REG_SZ, rootKey)
  else begin
    zero := #0;
    result := setRegValue(path, keyName, zero, sizeOf(zero), REG_SZ, rootKey);
  end;
end;

// --  --
function enableAutorun(doEnable: bool; const appPath: wString): bool;
const
  c_run_path = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Run';
var
  path: wString;
  res: long;
  key: hKey;
begin
  if ('' = appPath) then
    path := paramStr(0)
  else
    path := trimS(appPath, true);
  //
  if (doEnable) then
    result := (ERROR_SUCCESS = setRegValue(c_run_path, aString(path), aString(path), HKEY_LOCAL_MACHINE))
  else begin
    //
    res :=  RegCreateKeyEx(HKEY_LOCAL_MACHINE, c_run_path, 0{reserved}, nil{class, must be NULL}, REG_OPTION_NON_VOLATILE, KEY_WRITE, nil{security}, key, nil);
    if (ERROR_SUCCESS = res) then begin
      //
      try
{$IFNDEF NO_ANSI_SUPPORT }
	if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
 	  RegDeleteValueW(key, pwChar(path))
{$IFNDEF NO_ANSI_SUPPORT }
        else
 	  RegDeleteValueA(key, paChar(aString(path)));
{$ENDIF NO_ANSI_SUPPORT }
        ;
        //
	result := true;
      finally
	RegCloseKey(key);
      end;
    end
    else
      result := false;
  end;
end;

// --  --
function processMessages(wnd: hWnd): unsigned;
var
  msg: TMsg;
begin
  result := 0;
  //
  while (PeekMessage(msg, wnd, 0, 0, PM_REMOVE)) do begin
    //
    TranslateMessage(msg);
    DispatchMessage(msg);
    inc(result);
  end;
end;


  //

// --  --
function winEnvVar(const name: wString; buf: pwChar; size: DWORD): int;
{$IFNDEF NO_ANSI_SUPPORT }
var
  bufA: paChar;
{$ENDIF NO_ANSI_SUPPORT }
begin
{$IFNDEF NO_ANSI_SUPPORT }
  if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
    result := GetEnvironmentVariableW(pwChar(name), buf, size)
{$IFNDEF NO_ANSI_SUPPORT }
  else begin
    //
    bufA := malloc(size);
    try
      result := GetEnvironmentVariableA(paChar(aString(name)), bufA, size);
      strCopy(buf, string(bufA), size);
    finally
      mrealloc(bufA);
    end;
  end;
{$ENDIF NO_ANSI_SUPPORT }
end;


// --  --
function getEnvVar(const name: wString): wString;
const
  c_bufSize = 1024;
var
  len: int;
  buf: array[0..c_bufSize - 1] of wChar;
begin
  result := '';
  len := winEnvVar(name, buf, c_bufSize);
  if (len < c_bufSize) then
    result := buf
  else begin
    //
    setLength(result, len - 1);
    winEnvVar(name, pwChar(result), len);
  end;
end;

// --  --
function execApp(const moduleAndParams: wString; waitForExit: bool; showFlags: WORD; redirectFromWOW64: bool): int;

{$IFDEF FPC }
  {$DEFINE NEED_STARTUPINFO }
{$ENDIF FPC }

{$IFDEF __BEFORE_D9__ }
  {$DEFINE NEED_STARTUPINFO }
{$ENDIF __BEFORE_D9__ }

{$IFDEF NEED_STARTUPINFO }
type
  STARTUPINFOA = STARTUPINFO;
  STARTUPINFOW = STARTUPINFOA;
{$ENDIF NEED_STARTUPINFO }
var
  sia: STARTUPINFOA;
  siw: STARTUPINFOW;
  pi: PROCESS_INFORMATION;
  exitCode: DWORD;
  //
  cmdLine: wString;
  //
  ok: bool;
begin
  fillChar(sia, sizeOf(sia), #0);
  fillChar(siw, sizeOf(siw), #0);
  //
  sia.cb := sizeOf(sia);
  siw.cb := sizeOf(siw);
  siw.dwFlags := STARTF_USESHOWWINDOW;
  siw.wShowWindow := showFlags;
  //
  fillChar(pi, sizeOf(pi), #0);
  //
  if (redirectFromWOW64) then
    cmdLine := getEnvVar('windir') + '\Sysnative\' + moduleAndParams
  else
    cmdLine := moduleAndParams;
  //
{$IFNDEF NO_ANSI_SUPPORT }
  if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
    ok := CreateProcessW(nil, pwChar(cmdLine), nil, nil, false, 0, nil, nil, siw, pi)
{$IFNDEF NO_ANSI_SUPPORT }
  else
    ok := CreateProcessA(nil, paChar(aString(cmdLine)), nil, nil, false, 0, nil, nil, sia, pi);
{$ENDIF NO_ANSI_SUPPORT }
  ;
  //
  if (ok) then begin
    //
    if (waitForExit) then begin
      //
      result := -2;
      //
      repeat
	//
	Sleep(100);
	processMessages();
	//
	if ((GetExitCodeProcess(pi.hProcess, exitCode)) and
	    (STILL_ACTIVE = exitCode)) then
	  // continue wait
	  continue
	else begin
	  //
	  CloseHandle(pi.hProcess);
	  CloseHandle(pi.hThread);
	  result := exitCode;
	  //
	  break;
	end;
	//
      until (false);
      //
    end
    else
      result := 0;
  end
  else
    result := GetLastError();
end;

// --  --
function execApp(const module, params: wString; waitForExit: bool; showFlags: WORD; redirectFromWOW64: bool): int;
begin
  result := execApp(module + ' ' + params, waitForExit, showFlags, redirectFromWOW64);
end;

// --  --
function locateProcess(var procEntryW: PROCESSENTRY32W; const exeName: wString): bool;
var
  procEntriesW: pprocessEntryArrayW;
  count: int;
  notMe: bool;
begin
  notMe := ('' = trimS(exeName, true));
  //
  procEntriesW := nil;
  count := locateProcesses(procEntriesW, exeName);
  try
    result := (0 < count);
    if (result) then begin
      //
      if (notMe) then begin
	//
	result := false;
	while (0 < count) do begin
          //
	  if (procEntriesW[count - 1].th32ProcessID = GetCurrentProcessID()) then
	    dec(count)
	  else begin
            //
	    procEntryW := procEntriesW[count - 1];
	    result := true;
	    break;
	  end;
	end;
      end
      else
	procEntryW := procEntriesW[0];
    end;
    //
  finally
    mrealloc(procEntriesW);
  end;
end;

{$IFDEF FPC }

//
// The th32ProcessID argument is only used if TH32CS_SNAPHEAPLIST or
// TH32CS_SNAPMODULE is specified. th32ProcessID == 0 means the current
// process.
//
// NOTE that all of the snapshots are global except for the heap and module
//  lists which are process specific. To enumerate the heap or module
//  state for all WIN32 processes call with TH32CS_SNAPALL and the
//  current process. Then for each process in the TH32CS_SNAPPROCESS
//  list that isn't the current process, do a call with just
//  TH32CS_SNAPHEAPLIST and/or TH32CS_SNAPMODULE.
//
// dwFlags
//
const
  TH32CS_SNAPHEAPLIST = $00000001;
  TH32CS_SNAPPROCESS  = $00000002;
  TH32CS_SNAPTHREAD   = $00000004;
  TH32CS_SNAPMODULE   = $00000008;
  TH32CS_SNAPALL      = TH32CS_SNAPHEAPLIST or TH32CS_SNAPPROCESS or TH32CS_SNAPTHREAD or TH32CS_SNAPMODULE;
  TH32CS_INHERIT      = $80000000;
//

function CreateToolhelp32Snapshot(dwFlags, th32ProcessID: DWORD): THandle; stdcall; external kernel32 name 'CreateToolhelp32Snapshot';
function Process32FirstW(hSnapshot: THandle; var lppe: TProcessEntry32W): BOOL; stdcall; external kernel32 name 'Process32FirstW';
function Process32NextW(hSnapshot: THandle; var lppe: TProcessEntry32W): BOOL; stdcall; external kernel32 name 'Process32NextW';


{$ENDIF FPC }

// --  --
function locateProcesses(var procEntriesW: pprocessEntryArrayW; const exeName: wString): int;
var
  name: wString;
  shot: tHandle;
  procEntryW: PROCESSENTRY32W;
  ok: bool;
begin
  result := 0;
  mrealloc(procEntriesW);
  //
  name := lowerCase(trimS(exeName));
  if ('' = name) then
    name := lowerCase(extractFileName(paramStr(0)));
  //
  procEntryW.dwSize := sizeOf(procEntryW);
  shot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if (0 <> shot) then begin
    //
    try
      ok := Process32FirstW(shot, procEntryW);
      while (ok) do begin
	//
	if (1 <= pos(name, string(lowerCase(procEntryW.szExeFile)))) then begin
	  //
	  inc(result);
	  mrealloc(procEntriesW, result * sizeOf(procEntriesW[0]));
	  procEntriesW[result - 1] := procEntryW;
	end;
	//
	procEntryW.dwSize := sizeOf(procEntryW);
	ok := Process32NextW(shot, procEntryW);
      end;
      //
    finally
      CloseHandle(shot);
    end;
  end;
end;

// --  --
function windowEnumProc(wnd: hWnd; param: LPARAM): bool; stdcall;
var
  wnds: pHandleArray;
begin
  wnds := pointer(param);
  inc(wnds[0]);
  mrealloc(wnds, (1 + wnds[0]) * sizeOf(wnds[0]));
  wnds[wnds[0]] := wnd;
  result := true;
end;

// --  --
function windowsEnum(var wnds: pHandleArray): unsigned;
begin
  mrealloc(wnds, 4096 * sizeOf(wnds[0]));
  wnds[0] := 0;
  EnumWindows(@windowEnumProc, UIntPtr(wnds));
  result := wnds[0];
end;

// --  --
function windowEnumChildProc(wnd: hWnd; param: LPARAM): bool; stdcall;
begin
  if (0 <> param) then
    pHandle(param)^ := wnd;
  //
  result := false;	// stop it
end;

// --  --
function windowGetFirstChild(parent: hWnd): hWnd;
begin
  EnumChildWindows(parent, @windowEnumChildProc, Windows.LPARAM(@result));
end;

// --  --
function getProcessWindows(var wnds: pHandleArray; processId: unsigned): unsigned;
var
  i: int;
  procID: DWORD;
  myWnds: pHandleArray;
begin
  if (0 = processId) then
    processId := GetCurrentProcessID();
  //
  result := 0;
  mrealloc(wnds, (1 + result) * sizeOf(wnds[0]));
  wnds[0] := result;
  //
  myWnds := nil;
  windowsEnum(myWnds);
  try
    i := 0;
    while (i < int(myWnds[0])) do begin
      //
      GetWindowThreadProcessId(myWnds[1 + i], @procId);
      if (procId = processId) then begin
	//
	inc(wnds[0]);
	mrealloc(wnds, (1 + wnds[0]) * sizeOf(wnds[0]));
	wnds[wnds[0]] := myWnds[1 + i];
      end;
      //
      inc(i);
    end;
  finally
    mrealloc(myWnds);
  end;
  //
  result := wnds[0];
end;

// --  --
function checkIfDuplicateProcess(doFlashWindow: bool): unsigned;
var
  process: PROCESSENTRY32W;
  wnds: pHandleArray;
  wnd: hWnd;
begin
  if (locateProcess(process)) then begin
    //
    if (doFlashWindow) then begin
      //
      wnds := nil;
      try
	if (0 < getProcessWindows(wnds, process.th32ProcessID)) then begin
	  //
	  while (0 < wnds[0]) do begin
	    //
	    wnd := wnds[wnds[0]];
	    if (0 <> (WS_VISIBLE and GetWindowLong(wnd, GWL_STYLE))) then begin
	      //
	      ShowWindow(wnd, SW_RESTORE);
	      BringWindowToTop(wnd);
	      FlashWindow(wnd, True);
	      FlashWindow(wnd, False);
	    end;
	    dec(wnds[0]);
	    //
	  end;
	end;
	//
      finally
	mrealloc(wnds);
      end;
    end;
    //
    result := process.th32ProcessID;
  end
  else
    result := 0;
end;

// --  --
function checkIfDuplicateProcess(const mutexName: wString; var mutex: tHandle; closeIfFound: bool): bool;
begin
{$IFNDEF NO_ANSI_SUPPORT }
  if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
    mutex := OpenMutexW(MUTEX_ALL_ACCESS, false, pwChar(mutexName))
{$IFNDEF NO_ANSI_SUPPORT }
  else
    mutex := OpenMutexA(MUTEX_ALL_ACCESS, false, paChar(aString(mutexName)));
{$ENDIF NO_ANSI_SUPPORT }
  ;
  //
  if (0 <> mutex) then begin
    //
    result := true;
    //
    if (closeIfFound) then
      CloseHandle(mutex);
    //
  end
  else begin
    //
{$IFNDEF NO_ANSI_SUPPORT }
    if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
      mutex := CreateMutexW(nil, true, pwChar(mutexName))
{$IFNDEF NO_ANSI_SUPPORT }
    else
      mutex := CreateMutexA(nil, true, paChar(aString(mutexName)));
{$ENDIF NO_ANSI_SUPPORT }
    ;
    //
    if (ERROR_ALREADY_EXISTS = GetLastError()) then begin
      //
      // someone was faster than we
      result := true;
      //
      if (closeIfFound) then
	CloseHandle(mutex);
    end
    else
      result := false;
    //
  end;
end;

// --  --
function setPriority(value: int): int;
begin
  if (SetThreadPriority(GetCurrentThread(), value)) then
    result := 0
  else
    result := GetLastError();
end;

// --  --
function getPriority(): int;
begin
  result := GetThreadPriority(GetCurrentThread());
end;

// --  --
function putIntoClipboard(const data: aString; window: hWnd): int;
var
  sz: DWORD;
  hglbCopy: HGLOBAL;
  lptstrCopy: pointer;
begin
  result := -1;
  //
  if (OpenClipboard(window)) then begin
    //
    EmptyClipboard();
    try
      sz := length(data) + 1;
      hglbCopy := GlobalAlloc(GMEM_MOVEABLE, sz);
      if (0 <> hglbCopy) then begin
	//
	lptstrCopy := GlobalLock(hglbCopy);
	move(data[1], lptstrCopy^, sz);	// copy all characters, including #0
	GlobalUnlock(hglbCopy);
	// put data into clipboard
	SetClipboardData(CF_TEXT, hglbCopy);
	//
	result := 0;
      end;
    finally
      CloseClipboard();
    end;
  end;
end;

// --  --
procedure mfill16(mem: pointer; count: unsigned; value: uint16);
begin
  asm
	push	edi
	//
	mov	edi, mem
	mov	ax, value
	mov	ecx, count
	//
  @loop:
	stosw
	loop	@loop
	//
	pop	edi
  end;
end;


{$IFDEF UNAUTILS_MEM_USE_HEAP_CALLS }
var
  g_heap: tHandle;
{$ENDIF UNAUTILS_MEM_USE_HEAP_CALLS }

// --  --
function malloc(size: unsigned; doFill: bool; fill: byte): pointer;
begin
  if (0 < size) then begin
    //
{$IFDEF UNAUTILS_MEM_USE_HEAP_CALLS }
    result := HeapAlloc(g_heap, HEAP_GENERATE_EXCEPTIONS, size);
{$ELSE }
    getMem(result, size);
{$ENDIF UNAUTILS_MEM_USE_HEAP_CALLS }
    //
    if (nil <> result) then begin
      //
    {$IFDEF LOG_UNAUTILS_MALLOCS }
      logMessage('MA: ' + adjust(int2str(size), 6) + ' -> ' + adjust(int2str(unsigned(result), 16), 8), c_logModeFlags_noOL or g_infoLogMessageFlags);
    {$ENDIF LOG_UNAUTILS_MALLOCS }
      //
{$IFDEF UNAUTILS_DEBUG_MEM }
      //
      EnterCriticalSection(g_memLock);
      try
	//inc(g_allocMemSize, size);
	asm
	  // try to locate empty spot in array
	  sub	ecx, ecx		// value
	  lea	eax, g_allocMemPtr	// buf
	  mov	edx, g_allocMemCount	// count
	  call	mscand
	  or	eax, eax
	  jz	@@doAdd
	  //
	  // we have found a spot, put new ptr there
	  sub	eax, offset g_allocMemPtr
	  mov	ecx, eax
	  //
	  jmp	@@put
    @@doAdd:
	  //
	  mov	ecx, 1
     lock xadd	[g_allocMemCount], ecx	// temp <= ecx + [g_allocMemCount]
					  // ecx <= [g_allocMemCount]
					  // [g_allocMemCount] <= temp
	  //
	  cmp	ecx, c_maxAllocEntries
	  jae	@@done	// mo more space in array
	  //
	  shl	ecx, 2	// convert index to offset
    @@put:
	  mov	eax, result
	  mov	edx, size
	  //
	  mov	dword ptr g_allocMemPtr[ecx], eax	// ptr
	  mov	dword ptr g_allocMemSz [ecx], edx	// size
    @@done:
	  mov	edx, size
    lock  xadd	[g_allocMemSize], edx
	  //
	end;
	//
      finally
	LeaveCriticalSection(g_memLock);
      end;
      //
{$ENDIF UNAUTILS_DEBUG_MEM }
      //
      if (doFill) then
	fillChar(result^, size, fill and $FF);
    end;
  end
  else
    result := nil;
end;

// --  --
function malloc(size: unsigned; data: pointer): pointer;
begin
  result := malloc(size);
  //
  if ((nil <> result) and (nil <> data) and (0 < size)) then
    move(data^, result^, size);
end;

{$IFDEF UNAUTILS_DEBUG_MEM }

// --  --
function getAllocSize(p: pointer): unsigned; assembler;
asm
	mov	ecx, eax		// value
	lea	eax, g_allocMemPtr	// buf
	mov	edx, g_allocMemCount	// count
	call	mscand
	sub	ecx, ecx	// assume zero size if not found
	or	eax, eax
	jz	@@notFound
	//
	sub	eax, offset g_allocMemPtr // get offset
	mov	ecx, dword ptr g_allocMemSz[eax]
	jmp	@@done
	//
@@notFound:
	mov	ecx, -1
	mov	eax, ecx
@@done:
	xchg	eax, ecx
end;

{$ENDIF UNAUTILS_DEBUG_MEM }

//var
//  g_inRM: bool;

// --  --
procedure rm(var p: pointer; size: int);
{$IFDEF LOG_UNAUTILS_MALLOCS }
var
  pbefore: pointer;
  s: string;
{$ENDIF LOG_UNAUTILS_MALLOCS }
begin
{$IFDEF LOG_UNAUTILS_MALLOCS }
  pbefore := p;
{$ENDIF LOG_UNAUTILS_MALLOCS }
  //
{$IFDEF UNAUTILS_MEM_USE_HEAP_CALLS }
  //
  if (nil = p) then begin
    //
    if (0 < size) then
      p := HeapAlloc(g_heap, HEAP_GENERATE_EXCEPTIONS, size);
  end
  else begin
    //
    if (0 < size) then
      p := HeapReAlloc(g_heap, HEAP_GENERATE_EXCEPTIONS, p, size)
    else begin
      //
      HeapFree(g_heap, HEAP_GENERATE_EXCEPTIONS, p);
      p := nil;
    end;
  end;
  //
{$ELSE }
  reallocMem(p, size);
{$ENDIF UNAUTILS_MEM_USE_HEAP_CALLS }
  //
{$IFDEF LOG_UNAUTILS_MALLOCS }
  if (nil <> pbefore) then
    s := 'RM: ' + adjust(int2str(unsigned(pbefore), 16), 8) + ' / ' + adjust('?', 6) + ' -> ' + adjust(int2str(size), 6) + ' / ' + adjust(int2str(unsigned(p), 16), 8)
  else
    s := 'RM: ' + adjust(int2str(unsigned(pbefore), 16), 8) + ' / ' + adjust(int2str(0), 6) +                     ' -> ' + adjust(int2str(size), 6) + ' / ' + adjust(int2str(unsigned(p), 16), 8);
  //
  logMessage(s, c_logModeFlags_noOL or g_infoLogMessageFlags);
  //
{$ENDIF LOG_UNAUTILS_MALLOCS }
end;


procedure mrealloc(var data; newSize: unsigned);
begin
  rm(pointer(data), newSize);
end;

(*

// --  --
{$IFDEF __AFTER_D9__ }	// Delphi 2006 or later

// Delphi 2006 and later use new smart MM, so use it by default

function mrealloc(var data; newSize: unsigned): pointer; assembler;
asm
	// IN:
	//   	EAX = @data
	//   	EDX = newSize
	//
	// OUT:
	//	EAX = pointer
	//
{$IFDEF UNAUTILS_DEBUG_MEM }
	//
	push	ebx
	push	esi
	push	edi
	//
	mov	esi, eax
	mov	ebx, edx
	//
	push	offset g_memLock
	call	EnterCriticalSection
	//
	// check if data is not NIL
	mov	edi, -1
	mov	ecx, [esi]	// ECX = pointer(data)
	or	ecx, ecx
	je	@@rm	// data = nil
	//
	mov	eax, [esi]
	call	getAllocSize
	cmp	eax, edi
	mov	edi, ecx
	je	@@rm
	//
	neg	eax
  lock 	xadd	[g_allocMemSize], eax
	//
@@rm:
	mov	edx, ebx	// restore size
	mov	eax, esi        // restore data
{$ELSE }
	push	eax
{$ENDIF UNAUTILS_DEBUG_MEM }
	call 	rm
{$IFDEF UNAUTILS_DEBUG_MEM }
	mov	eax, [esi]
	mov	esi, eax
	//
	cmp	edi, -1
	je	@@skipZ
	//
	sub	ecx, ecx
	mov	dword ptr g_allocMemPtr[edi], ecx	// zero ptr
	mov	dword ptr g_allocMemSz [edi], ecx	// zero sz
	//
@@skipZ:
	or	eax, eax
	jz	@@exit	// new ptr is nil
	//
@@tryAdd:
	//
	// try to locate empty spot in array
	sub	ecx, ecx		// value
	lea	eax, g_allocMemPtr	// buf
	mov	edx, g_allocMemCount	// count
	call	mscand
	or	eax, eax
	jz	@@doAdd
	//
	// we have found a spot, put new ptr there
	sub	eax, offset g_allocMemPtr
	mov	ecx, eax
	//
	jmp	@@put
	//
@@doAdd:
	//
	mov	ecx, 1
   lock xadd	[g_allocMemCount], ecx	// temp <= ecx + [g_allocMemCount]
					// ecx <= [g_allocMemCount]
					// [g_allocMemCount] <= temp
	//
	cmp	ecx, c_maxAllocEntries
	jae	@@done		// mo more space in array
	//
	shl 	ecx, 2		// convert index to offset
@@put:
	mov	dword ptr g_allocMemPtr[ecx], esi	// ptr
	mov	dword ptr g_allocMemSz [ecx], ebx	// size
	//
@@done:
  lock	xadd	[g_allocMemSize], ebx
	//
@@exit:
	push	offset g_memLock
	call	LeaveCriticalSection
	//
	mov	eax, esi
	//
	pop	edi
	pop	esi
	pop	ebx
{$ELSE }
	pop	ecx
	{$IFDEF FPC }
	mov	eax, [{$IFDEF CPU64 }rcx{$ELSE }ecx{$ENDIF CPU64 }]
	{$ELSE }
	mov	eax, [ecx]
	{$ENDIF FPC }
{$ENDIF UNAUTILS_DEBUG_MEM }
end;

{$ELSE }

// Delphi 2005 and earlier use strange MM, so help it to be a little smarter

function mrealloc(var data; newSize: unsigned): pointer; assembler;
asm
	// IN:
	//	EAX = @data
	//	EDX = newSize

	// OUT:
	//	result = EAX = new pointer

	//  newSize := ((newSize + 511) shr 9) shl 9
	add	edx, 511
	shr	edx, 9
	shl 	edx, 9

	//
	or	edx, edx
	// save eax
	mov	ecx, eax
	je	@@bother	// if newSize = 0

	mov	ecx, eax
	mov	ecx, [ecx]	// ECX = pointer(data)
	or	ecx, ecx
	// save eax
	mov	ecx, eax
	je	@@bother	// or data = nil

	// check if realloc is really required

	mov	eax, [eax]	// EAX = pointer(data)

	//
	// get current size allocated
	// NOTE: THE CODE BELOW DEPENDS ON GETMEM.INC IMPLEMENATION!
	//       (WHICH SEEMS TO BE NOT CHANGED SINCE DELPHI 2 UP TO DELPHI 2005)
	//
	sub	eax, 4
	mov	eax, [eax]
	and	eax, $7FFFFFFC
	sub	eax, 4

	// check if new size is the same as allocated
	// for some reason Borland implementation did not perform this check
	cmp	eax, edx

	// restore @data
	mov	eax, ecx

	je	@@noBother	// skip reallocMem call

  @@bother:
	// reallocMem(pointer(data), newSize)
	//
	// due to "smart" implementation of reallocMem, it is not possible to call it directly
	//
	push	ecx
	call	rm
	pop	ecx

  @@noBother:
	// result = [ecx]
	mov	eax, [ecx]
end;

{$ENDIF __AFTER_D9__ }

*)

// --  --
function mcompare(p1, p2: pointer; size: unsigned): bool; assembler;
asm
	push    esi
	push    edi

	mov     esi, p1
	mov     edi, p2
	mov     edx, ecx	// size
	xor     eax, eax	// false

	and     edx, 3		// last 0..3 bytes (000, 001, 010, 011)
	shr     ecx, 1		// div 2
	shr     ecx, 1		// div 2

	repe    cmpsd		// compare dwords
	jne     @@exit

	mov     ecx, edx	// number of last 0..3 bytes
	repe    cmpsb		// compare bytes
	jne     @@exit

	inc     eax  	// true

@@exit: pop     edi
	pop     esi
end;

// --  --
function mscanb(buf: pointer; count: unsigned; value: uint8): pointer; assembler;
{
	IN:	EAX = buf
		EDX = count
		ECX = value
	OUT:
		EAX = result
}
asm
	or	eax, eax
	je	@exit

	push	edi
	mov	edi, eax
	mov	eax, ecx
	mov	ecx, edx

	// cld			it looks to be assumed
	or	edi, edi	// reset ZF
	jecxz	@skip

	repne	scasb
  @skip:
	mov	eax, ecx	// ecx will be 0 if nothing was found
	jne	@none

	mov	eax, edi
	dec	eax
  @none:
	pop	edi
  @exit:
end;

// --  --
function mscanw(buf: pointer; count: unsigned; value: uint16): pointer; assembler;
{
	IN:	EAX = buf
		EDX = count
		ECX = value
	OUT:
		EAX = result
}
asm
	or	eax, eax
	je	@exit

	test	eax, $01	// chek proper alingment
	jz	@OK

	or	edx, edx	// zero lenght?
	jnz	@OK

  @notOK:
	sub	eax, eax
	jmp	@exit

  @OK:
	or	edx, edx	// zero lenght?
	jz	@notOK

	push	edi
	mov	edi, eax
	mov	eax, ecx
	mov	ecx, edx

	// cld			assumed
	or	edi, edi	// reset ZF
	jecxz	@skip

	repne	scasw
  @skip:
	mov	eax, ecx        // ecx will be 0 if nothing was found
	jne	@none

	mov	eax, edi
	dec	eax
	dec	eax
  @none:
	pop	edi
  @exit:
end;

// --  --
function mscand(buf: pointer; count: unsigned; value: uint32): pointer; assembler;
{
	IN:	EAX = buf
		EDX = count
		ECX = value
	OUT:
		EAX = result
}
asm
	or	eax, eax
	je	@exit

	test	eax, $03	// chek proper alingment
	jz	@OK

  @notOK:
	sub	eax, eax
	jmp	@exit

  @OK:
	or	edx, edx	// zero count?
	jz	@notOK

	push	edi
	mov	edi, eax	// buf
	mov	eax, ecx	// value
	mov	ecx, edx	// count

	// cld			// assumed
	or	edi, edi	// reset ZF
	jecxz	@skip

	repne	scasd
  @skip:
	mov	eax, ecx	// ecx will be 0 if nothing was found
	jne	@none

	mov	eax, edi
	sub	eax, 4
  @none:
	pop	edi

  @exit:
end;

// --  --
function mscanq(buf: pointer; count: unsigned; const value: int64): pointer;
var
  bufd: pUint32;
  maxBuf: UIntPtr;
begin
  result := nil;
  //
  if ((0 < count) and (nil <> buf)) then begin
    //
    bufd := buf;
    maxBuf := UIntPtr(bufd) + count shl 3;
    repeat
      //
  {
    bytes:  [00] [01] [02] [03] [04] [05] [06] [07] [08] [09] [0A] [0B] [0C] [0D] [0E] [0F]

    words:  [00.....] [01.....] [02.....] [03.....] [04.....] [05.....] [06.....] [07.....]

   dwords:  [00...............] [01...............] [02...............] [03...............]

   qwords:  [00...................................] [01...................................]

	     ^                   ^                   ^
	     |                   |                   |
	     n_bytes  = 16       n_bytes  = 12       n_bytes  = 8
	     n_words  = 8        n_words  = 6        n_words  = 4
	     n_dwords = 4        n_dwords = 3        n_dwords = 2
	     n_qwords = 2        n_qwords = X        n_qwords = 1
  }
      //
      result := mscand(bufd, count shl 1 - 1, uint32(value));
      if (nil <> result) then begin
	//
	if (0 = ((UIntPtr(result) - UIntPtr(bufd)) and $07)) then begin
	  //
	  bufd := result;
	  inc(bufd);
	  // found first part, lets check if next dword matches
	  if (bufd^ = uint32(value shr 32)) then
	    // found, exit
	    break
	  else
	    // skip to next qword
	    result := nil;	// not found yet
	  //
	end
	else begin
	  //
	  // delta is not qword aligned, align to next qword
	  bufd := result;
	  result := nil;
	end;
      end
      else
	break;	// not found
      //
      inc(bufd);
      count := (maxBuf - UIntPtr(bufd)) shr 3;
      //
    until (1 > count);
  end;
end;

// --  --
function mscanbuf(buf: pointer; bufSize: unsigned; value: pointer; valueLen: unsigned): pointer;
var
  offs: unsigned;
  c: unsigned;
begin
  result := nil;
  //
  if ((0 < bufSize) and (0 < valueLen)) then begin
    //
    if (1 = valueLen) then
      result := mscanb(buf, bufSize, pArray(value)[0])
    else begin
      //
      offs := 0;
      repeat
	//
	while ((offs < bufSize) and (pArray(buf)[offs] <> pArray(value)[0])) do
	  inc(offs);
	//
	if ((offs < bufSize) and (pArray(buf)[offs] = pArray(value)[0])) then begin
	  //
	  c := 1;
	  inc(offs);
	  //
	  while ((offs < bufSize) and (c < valueLen) and (pArray(buf)[offs] = pArray(value)[c])) do begin
	    //
	    inc(offs);
	    inc(c);
	  end;
	  //
	  if ((offs <= bufSize) and (c = valueLen)) then begin
	    //
	    result := @pArray(buf)[int(offs) - int(valueLen)];
	    break;
	  end;
	end;
	//
      until (offs >= bufSize);
      //
    end;
  end;
end;

// --  --
procedure mswapbuf16(buf: pointer; len: int);
begin
    asm
{$IFDEF CPU64 }
	push	ecx
	push	esi

	mov	esi, buf
	mov	ecx, len

  @loophere:
	cmp	ecx, 2
	jb	@stoploop

	mov	ax, [rsi]
	mov	ax, [rsi]
	xchg	al, ah
	mov	[rsi], ax
	mov	[rsi], ax
	inc	esi
	inc	esi
	dec	ecx
	dec	ecx
	jmp	@loophere

  @stoploop:
	pop	esi
	pop	ecx
{$ELSE }
	push	ecx
	push	esi

	mov	esi, buf
	mov	ecx, len

  @loophere:
	cmp	ecx, 2
	jb	@stoploop

	mov	ax, [esi]
	mov	ax, [esi]
	xchg	al, ah
	mov	[esi], ax
	mov	[esi], ax
	inc	esi
	inc	esi
	dec	ecx
	dec	ecx
	jmp	@loophere

  @stoploop:
	pop	esi
	pop	ecx
{$ENDIF CPU64 }
    end;
end;

// --  --
procedure freeAndNil(var objRef);
var
  ref: tObject;
begin
  ref := tObject(objRef);
  pointer(objRef) := nil;
  ref.free();
end;

// --  --
function waitForObject(handle: tHandle; timeout: unsigned): bool;
begin
  result := (WAIT_OBJECT_0 = WaitForSingleObject(handle, timeout));
end;

// --  --
function _acquire32(var a: unaAcquireType; ex: bool): bool;
begin
  asm
  {$IFDEF CPU64 }
	xor	rcx, rcx
	mov	ecx, a
	xor	rax, rax
	inc	rax

   lock	xadd 	[rcx], rax

	cmp	rax, 0
	setz 	al
	neg	al
	sbb	rax, rax
	mov	result, rax
  {$ELSE }
	mov	ecx, a
	xor	eax, eax
	inc	eax

   lock	xadd 	[ecx], eax

	cmp	eax, 0
	setz 	al
	neg	al
	sbb	eax, eax
	mov	result, eax
  {$ENDIF CPU64 }
  end;
  //
  if (not result and ex) then
    release32(a);
end;

// --  --
procedure acquire32(var a: unaAcquireType);
begin
  _acquire32(a, false);
end;

// --  --
function acquire32(var a: unaAcquireType; timeout: int): bool;
var
  tm: int64;
begin
  tm := 0;
  repeat
    if (0 > timeout) then
      timeout := 10000;	// seems like INFINITE was passed
    //
    result := _acquire32(a, true);
    if (not result and (0 < timeout)) then begin
      //
      if (0 = tm) then
	tm := timeMark();
      //
      sleep(1 + timeout shr 8);
      //
      if (timeout < timeElapsed64(tm)) then
	break;
    end;
    //
  until (result or (0 >= timeout));
end;

// --  --
function release32(var a: unaAcquireType): bool;
begin
  {$IFDEF DEBUG }
  if (1 > a) then begin
    //
    logMessage('releaseObj() - invalid count (' + int2str(a) + '), will be reset to 1.');
    a := 1;
  end;
  {$ENDIF DEBUG }
  //
  asm
  {$IFDEF CPU64 }
	xor	rcx, rcx
	mov	ecx, a
	xor	rax, rax
	dec	rax

   lock	xadd 	[rcx], rax

	cmp	rax, 1
	setz 	al
	neg	al
	sbb	rax, rax

	mov	result, rax
  {$ELSE }
	mov	ecx, a
	xor	eax, eax
	dec	eax

   lock	xadd 	[ecx], eax

	cmp	eax, 1
	setz 	al
	neg	al
	sbb	eax, eax

	mov	result, eax
  {$ENDIF CPU64 }
  end;
end;

// --  --
function hrpc_query(): int64;
begin
  if (QueryPerformanceFrequency(result)) then
  else
    result := 0;
  //
  hrpc_Freq := result;
  hrpc_FreqFail := (1 > result);
  //
  if (not hrpc_FreqFail) then
    hrpc_FreqMs := hrpc_Freq div 1000;
end;

// --  --
function hrpc_mark(): int64; {$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
begin
  if (QueryPerformanceCounter(result)) then
  else
    result := 0;
end;

// --  --
function hrpc_getTimeInterval64(const mark: int64): int64; {$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
var
  newMark: int64;
begin
  newMark := hrpc_Mark();
  if (0 < newMark) then
    //
    result := newMark - mark
  else
    result := 0;
end;

// --  --
function hrpc_getTimeInterval(const mark: int64): unsigned; {$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
var
  delta: int64;
begin
  delta := hrpc_getTimeInterval64(mark);
  //
  if (0 < hrpc_FreqMs) then
    result := (delta div hrpc_FreqMs) and $FFFFFFFF
  else
    result := 0;
end;

// --  --
function timeMark(): int64;
begin
  if (hrpc_FreqFail) then
    result := GetTickCount()
  else
    result := hrpc_Mark();
end;

// --  --
function timeElapsed32(mark: int64): unsigned;
begin
  if (hrpc_FreqFail) then
    result := GetTickCount() - mark
  else
    result := hrpc_getTimeInterval(mark);
end;

// --  --
function timeElapsed64ticks(mark: int64): int64;
begin
  result := hrpc_getTimeInterval64(mark);
end;

// --  --
function timeElapsed64(mark: int64): int64;
begin
  if (not hrpc_FreqFail) then
    result := (hrpc_getTimeInterval64(mark) div hrpc_FreqMs) and $7FFFFFFFFFFFFFFF
  else
    result := timeElapsed32(mark);
end;


// --  --
function sanityCheck(var mark: int64; maxSlice, sleepSlice: unsigned; careMessages: bool): bool;
begin
  result := sanityCheck64(mark, maxSlice, sleepSlice, careMessages);
end;

// --  --
function sanityCheck64(var mark: int64; maxSlice: int64; sleepSlice: unsigned; careMessages: bool): bool;
begin
  result := false;
  //
  if (0 = mark) then
    mark := timeMark()
  else
    if (maxSlice < timeElapsed64(mark)) then begin
      //
      if (careMessages) then
	processMessages();
      //
      Sleep(sleepSlice);
      //
      mark := timeMark();
      result := true;
    end;
end;

// --  --
function getSysErrorText(errorCode: DWORD; avoidGetCall: bool): wString;
var
{$IFNDEF NO_ANSI_SUPPORT }
  bufA: array[0..4096] of aChar;
{$ENDIF NO_ANSI_SUPPORT }
  bufW: array[0..4096] of wChar;
  //
  res: int;
begin
  if (0 = errorCode) then begin
    //
    if (not avoidGetCall) then
      errorCode := GetLastError();
  end;
  //
{$IFNDEF NO_ANSI_SUPPORT }
  if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
    res := FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM, nil, errorCode, 0, bufW, 4096, nil)
{$IFNDEF NO_ANSI_SUPPORT }
  else
    res := FormatMessageA(FORMAT_MESSAGE_FROM_SYSTEM, nil, errorCode, 0, bufA, 4096, nil);
{$ENDIF NO_ANSI_SUPPORT }
  ;
  //
  if (0 < res) then begin
    //
{$IFNDEF NO_ANSI_SUPPORT }
    if (g_wideApiSupported) then
{$ENDIF NO_ANSI_SUPPORT }
      result := bufW
{$IFNDEF NO_ANSI_SUPPORT }
    else
      result := string(bufA);
{$ENDIF NO_ANSI_SUPPORT }
    ;
  end
  else
    result := 'System Error Code: ' + int2str(errorCode);
end;

// so many choices :)

// --  --
function choice(value: bool; true_choice: int; false_choice: int): int;
begin
  if (value) then
    result := true_choice
  else
    result := false_choice;
end;

// --  --
function choice(value: bool; true_choice: char; false_choice: char): char;
begin
  if (value) then
    result := true_choice
  else
    result := false_choice;
end;


{$IFDEF __BEFORE_DC__ }

// --  --
function choice(value: bool; true_choice: wChar; false_choice: wChar): wChar;
begin
  if (value) then
    result := true_choice
  else
    result := false_choice;
end;

{$ELSE }

// --  --
function choice(value: bool; true_choice: aChar; false_choice: aChar): aChar;
begin
  if (value) then
    result := true_choice
  else
    result := false_choice;
end;

{$ENDIF __BEFORE_DC__ }


// --  --
function choice(value: bool; true_choice: unsigned; false_choice: unsigned): unsigned;
begin
  if (value) then
    result := true_choice
  else
    result := false_choice;
end;


{$IFDEF __BEFORE_D6__ }
{$ELSE }

// --  --
function choice(value: bool; const true_choice: string; const false_choice: string): string;
begin
  if (value) then
    result := true_choice
  else
    result := false_choice;
end;

{$ENDIF __BEFORE_D6__ }


{$IFDEF __BEFORE_DC__ }

// --  --
function choice(value: bool; const true_choice: wString; const false_choice: wString): wString;
begin
  if (value) then
    result := true_choice
  else
    result := false_choice;
end;

{$ELSE }

// --  --
function choice(value: bool; const true_choice: aString; const false_choice: aString): aString;
begin
  if (value) then
    result := true_choice
  else
    result := false_choice;
end;

{$ENDIF __BEFORE_DC__ }

// --  --
function choice(value: bool; true_choice: boolean; false_choice: boolean): bool;
begin
  if (value) then
    result := true_choice
  else
    result := false_choice;
end;

// --  --
function choice(value: bool; true_choice: tObject; false_choice: tObject): tObject;
begin
  if (value) then
    result := true_choice
  else
    result := false_choice;
end;

// --  --
function choice(value: bool; true_choice: pointer; false_choice: pointer): pointer;
begin
  if (value) then
    result := true_choice
  else
    result := false_choice;
end;

// --  --
function choiceD(value: bool; const true_choice: double; false_choice: double): double;
begin
  if (value) then
    result := true_choice
  else
    result := false_choice;
end;

// --  --
function choiceE(value: bool; const true_choice: extended; false_choice: extended): extended;
begin
  if (value) then
    result := true_choice
  else
    result := false_choice;
end;

// --  --
function hasSwitchEx(const name: string; caseSensitive: bool; out num: int): bool;
var
  s: string;
  c: char;
begin
  result := false;
  num := 1;
  while (num <= paramCount()) do begin
    //
    s := paramStr(num);
    if ((1 < length(s)) and ((s[1] = '-') or (s[1] = '/') or (s[1] = '\'))) then begin
      //
      if (caseSensitive) then
	result := (copy(s, 2, length(s)) = name)
      else begin
	//
	if (2 < length(s)) then
	  c := copy(s, 2 + length(name), 1)[1]
	else
	  c := ' ';
	//
	if (('=' = c) or (':' = c)) then
	  result := (upperCase(copy(s, 2, length(name))) = upperCase(name))
	else
	  result := (upperCase(copy(s, 2, maxInt)) = upperCase(name))
      end;
      //
      if (result) then
	break;
    end;
    //
    inc(num);
  end;
  //
  if (not result) then
    num := -1;
end;

// --  --
function hasSwitch(const name: string; caseSensitive: bool): bool;
var
  i: int;
begin
  result := hasSwitchEx(name, caseSensitive, i);
end;

// --  --
function switchValue(const name: string; caseSensitive: bool; const defValue: string): string;
var
  i: int;
begin
  if (hasSwitchEx(name, caseSensitive, i)) then
    result := copy(paramStr(i), 3 + length(name), maxInt)
  else
    result := defValue;
  //
  if (('' <> result) and ((result[1] = ':') or (result[1] = '='))) then
    delete(result, 1, 1);
end;

// --  --
function switchValue(const name: string; caseSensitive: bool; defValue: int): int;
begin
  result := str2intInt(switchValue(name, caseSensitive, ''), defValue);
end;

// --  --
function gcd(a, b: unsigned): unsigned;
begin
  while ((0 < a) and (0 < b)) do begin
    //
    if (a > b) then
      a := a mod b
    else
      b := b mod a;
  end;
  //
  result := max(a, b);
end;


{$IFDEF __SYSUTILS_H_ }

// --  --
function float2str(const value: extended): string;
var
  i: integer;
begin
  result := floatToStrF(value, ffExponent, 18, 4);
  if ('.' <> decimalSeparator) then begin
    //
    i := length(result);
    while (i > 0) do begin
      //
      if (decimalSeparator = result[i]) then
	result[i] := '.';
      //
      dec(i);
    end;
  end;
end;

// --  --
function str2float(const value: string): extended;
var
  i: integer;
  res: string;
begin
  res := trimS(value);
  //
  if ('.' <> decimalSeparator) then begin
    //
    i := length(res);
    while (i > 0) do begin
      //
      if ('.' = res[i]) then
	res[i] := decimalSeparator;
      //
      dec(i);
    end;
  end;
  //
  result := strToFloat(res);
end;

{$ELSE }

// --  --
function float2str(const value: extended): string;
begin
  result := int2str(trunc(value)) + '.' + adjust(int2str(trunc(frac(value) * 1000000000)), 9, '0');
end;

{$ENDIF __SYSUTILS_H_ }


// -------------

type
  unaExceptClass = class of tobject;

{$IFNDEF FPC }

  // taken from SysUtils for Delphi IDE to work correctly
  pExceptionRecord = ^tExceptionRecord;
  tExceptionRecord = record
    //
    ExceptionCode: Cardinal;
    ExceptionFlags: Cardinal;
    ExceptionRecord: PExceptionRecord;
    ExceptionAddress: Pointer;
    NumberParameters: Cardinal;
    ExceptionInformation: array[0..14] of Cardinal;
  end;

{$ENDIF FPC }

// --  --
function getExceptionClass(p: pointer): unaExceptClass;
begin
  result := tObject;
end;

// --  --
function getExceptionObject(p: pExceptionRecord): tObject;
begin
  logMessage('Exception: code=' + int2str(p.ExceptionCode, 16) + ' at ' + wString(adjust(int2str(UIntPtr(p.exceptionAddress), 16), 8, '0')), c_logModeFlags_critical);
  result := nil;
end;

// --  --
procedure errorHandler(errorCode: byte; errorAddr: pointer); export;
begin
  logMessage('Error: code=' + int2str(errorCode) + ' @00' + int2str(UIntPtr(errorAddr), 16), c_logModeFlags_critical);
end;

// --  --
procedure exceptHandler(exceptObject: tObject; exceptAddr: pointer); //far; hm.. seems that is from Delphi 1, not?
begin
  logMessage('Exception: ' + exceptObject.ClassName + ' @00' + int2str(UIntPtr(exceptAddr), 16), c_logModeFlags_critical);
end;

// --  --
procedure assertErrorHandler(const message, filename: string; lineNumber: int; errorAddr: pointer);
begin
  logMessage('');
  logMessage('Assertion failed: ' + message + ' @00' + int2str(UIntPtr(errorAddr), 16));
  logMessage('Source: ' + filename + ' (' + int2str(lineNumber) + ')');
  logMessage('');
end;

// --  --
function setExceptionHandler(): bool;
begin
{$IFDEF FPC }
{$ELSE }
  exceptClsProc := @getExceptionClass;
  exceptObjProc := @getExceptionObject;
{$IFDEF __BEFORE_D6__ }
  // before Delphi 6.0
  errorProc := @errorHandler;
{$ELSE }
  errorProc := errorHandler;
{$ENDIF __BEFORE_D6__ }
  exceptProc := @exceptHandler;
{$ENDIF FPC }
  result := true;
end;

// --  --
function setAssertionHandler(): bool;
begin
{$IFDEF __AFTER_D5__ }
  assertErrorProc := TAssertErrorProc(@AssertErrorHandler);
{$ELSE }
  assertErrorProc := pointer(@AssertErrorHandler);
{$ENDIF __AFTER_D5__ }
  //
  result := true;
end;

// --  --
function doneExceptionAssertionHandlers(): bool;
begin
  exceptProc := nil;
  assertErrorProc := nil;
  result := true;
end;

{$IFDEF FPC }
type
  OSVERSIONINFOA = OSVERSIONINFO;
{$ENDIF FPC }

// --  --
type
  proc_IsWow64Process = function (hProcess: tHANDLE; out Wow64Process: bool): bool; stdcall;

// --  --
procedure getOSFeatures();
var
  ok: bool;
  ver: OSVERSIONINFOA;
  isWow64proc: proc_IsWow64Process;
begin
  g_osVersion.dwOSVersionInfoSize := sizeOf(g_osVersion);
  //
  {$IFDEF __AFTER_DB__ }
  ok := GetVersionExW(g_osVersion);
  {$ELSE }
    {$IFDEF FPC }
      ok := GetVersionExW(g_osVersion);
    {$ELSE }
      ok := GetVersionExW({work around Borland header translation bug}pOSVersionInfoA(@g_osVersion)^);
    {$ENDIF FPC }
  {$ENDIF __AFTER_DB__ }
  //
  if (not ok) then begin
    //
    // fill ANSI version
    ver.dwOSVersionInfoSize := sizeOf(ver);
    ok := GetVersionExA(ver);
    //
    if (ok) then begin
      //
      with g_osVersion do begin
	//
	dwMajorVersion := ver.dwMajorVersion;
	dwMinorVersion := ver.dwMinorVersion;
	dwBuildNumber  := ver.dwBuildNumber;
	dwPlatformId   := ver.dwPlatformId;
	//
	{$IFDEF __BEFORE_D6__ }
	  str2arrayW(wString(ver.szCSDVersion), szCSDVersion);
	{$ELSE }
	  str2array(wString(ver.szCSDVersion), szCSDVersion);
	{$ENDIF __BEFORE_D6__ }
      end;
    end;
  end;
  //
{$IFDEF NO_ANSI_SUPPORT }
  if (ok and (g_osVersion.dwMajorVersion < 5)) then
    // looks like we are running under Win98/95, notify about possible problems
    guiMessageBox('This code was compiled with no ANSI API support, and it seems that you are running the ANSI version of Windows.'#13#10 +
		  'There could be some compatibility issues, so it is recommended that you contact your software vendor to resolve this problem.', 'Incompatible OS version.', MB_ICONSTOP);
{$ELSE }
  if (ok) then begin
    //
    case (g_osVersion.dwPlatformId) of

      VER_PLATFORM_WIN32s,
      VER_PLATFORM_WIN32_WINDOWS: begin
	// win 3.1 or win9x/Me, no wide API
	g_wideApiSupported := false;
      end;

      VER_PLATFORM_WIN32_NT:
	g_wideApiSupported := true;

      else begin
	// should not be here, but assume wide anyway
	g_wideApiSupported := true;
      end;

    end;
  end
  else
    // hmm.. no version info, assume ANSI.
    g_wideApiSupported := false;
{$ENDIF NO_ANSI_SUPPORT }
  //
  g_isWOW64 := false;
  //
  //IsWow64Process is not available on all supported versions of Windows.
  isWow64proc := GetProcAddress(GetModuleHandle(kernel32), 'IsWow64Process');
  if (assigned(isWow64proc)) then
    if (not isWow64proc(GetCurrentProcess(), g_isWOW64)) then
      g_isWOW64 := false;	// isWow64proc fails, probably that means we are not under WOW64
  //
{$IFDEF CPU64 }
  g_inInc64 := GetProcAddress(GetModuleHandle(kernel32), 'InterlockedIncrement64');
  g_inDec64 := GetProcAddress(GetModuleHandle(kernel32), 'InterlockedDecrement64');
{$ENDIF CPU64 }
end;

{$IFDEF CHECK_MEMORY_LEAKS }

type
  // --  --
  pCallStack = ^tCallStack;
  tCallStack = packed record
    // NOTE: fillCallStack() has hard-coded offsets in this struct!
    r_threadId: unsigned;
    r_callStack: array[0..maxCallStackDepth - 1] of pointer;
  end;

var
  // --  --
  oldMM: tMemoryManager;

  gmc: int64;
  rmc: int64;
  fmc: int64;

  leakPointersArray : array[0..maxLeakEntries - 1] of pointer;
  leakCallStackArray: array[0..maxLeakEntries - 1] of tCallStack;

  g_imageBase: unsigned;
  g_isStarted: bool;
  g_maxStackSize: unsigned;

// --  --
procedure fillCallStack(entryIndex: int); assembler;
asm
	push	edi
	push	esi
	push	ebx

	//
	mov	ecx, 4 + 4 * maxCallStackDepth 	// sizeOf(tCallStack)
	imul	eax, ecx	// assuming EDX will be 0

	lea	edi, leakCallStackArray

	mov	edx, edi	// EDX will serve as max valid address
	add	edi, eax
	add	edi, 4		// offset to r_callStack

	// set eax to stack
	mov	eax, esp
	// skip known addresses
	add	eax, 12

	// max number of call stack entries
	mov	ecx, maxCallStackDepth

  @loop:
	// locate next call point
  @bad_ptr:
	add	eax, 4

	// check if are out of stack
	mov	ebx, esp
	add	ebx, g_maxStackSize	// max stack size
	cmp	eax, ebx

	mov	ebx, 0		// EBX = nil
				// FLAGS must not be changed!
	jae	@no_more_stack

	bt	eax, 15
	jnc	@no_more_stack	// stack is over

	mov	ebx, es:[eax]

	// check if this could be a call stack entry
	cmp	ebx, g_imageBase
	jbe	@bad_ptr

	cmp	ebx, edx
	jae	@bad_ptr

	// try to render this address as call instruction
	mov	esi, eax	// save EAX

	mov	ax, [ebx - 6]
	cmp	ax, $15FF
	jz	@check_done

	cmp	ah, $E8
	jz	@check_done

	mov	ax, [ebx - 3]
	cmp	ah, $FF
	jz	@check_done

	cmp	al, $FF
	jz	@check_done

	sub	eax, eax
	cmp	eax, 1		// ensure Z flag is not set

  @check_done:
	mov	eax, esi	// restore EAX

	jnz	@bad_ptr
	jmp	@store

  @no_more_stack:
	mov	eax, eax

  @store:
	xchg	eax, ebx
	stosd
	xchg	eax, ebx
	//

	loop	@loop

	pop	ebx
	pop	esi
	pop	edi
end;

// --  --
function _getMem(size: integer): pointer;
var
  ptr: pInt;
  index: int;
begin
  inc(gmc);
  result := oldMM.getMem(size);
  //
  ptr := mscand(@leakPointersArray, maxLeakEntries, 0);
  if (nil <> ptr) then begin
    //
    ptr^ := int(result);
    try
      index := (int(ptr) - int(@leakPointersArray)) div sizeOf(leakPointersArray[0]);
      if (0 <= index) then begin
	//
	fillCallStack(index);
	leakCallStackArray[index].r_threadId := GetCurrentThreadId();
      end;
    except
    end;
  end
  else
    ; // problem: out of entries
  //
end;

// --  --
function _freeMem(p: pointer): integer;
var
  ptr: pInt;
begin
  inc(fmc);
  result := oldMM.freeMem(p);
  //
  ptr := mscand(@leakPointersArray, maxLeakEntries, unsigned(p));
  if (nil <> ptr) then begin
    ptr^ := 0;
  end
  else
    ; // problem: no ptr was found
end;

// --  --
function _reallocMem(p: pointer; size: integer): pointer;
var
  ptr: pInt;
  index: int;
begin
  inc(rmc);
  result := oldMM.reallocMem(p, size);
  //
  ptr := mscand(@leakPointersArray, maxLeakEntries, unsigned(p));
  if (nil <> ptr) then begin
    //
    ptr^ := int(result);
    try
      index := (int(ptr) - int(@leakPointersArray)) div sizeOf(leakPointersArray[0]);
      if (0 <= index) then begin
	//
	fillCallStack(index);
	leakCallStackArray[index].r_threadId := GetCurrentThreadId();
      end;
    except
    end;
  end
  else
    ;// not our ptr
end;

const
  // --  --
  ourMM: tMemoryManager = (
    getMem: _getMem;
    freeMem: _freeMem;
    reallocMem: _reallocMem
  );

// --  --
procedure mleaks_start(maxStackSize: unsigned);
begin
  if (not g_isStarted) then begin
    //
    logMessage('--- MLeaks detection started ---');
    //
    g_isStarted := true;
    //
    asm
	push	eax

	lea	eax, ExitProcess	// take any system routine as a code base
	mov	g_imageBase, eax

	pop	eax
    end;
    //
    g_maxStackSize := maxStackSize;
    //
    fillChar(leakPointersArray,  sizeOf(leakPointersArray),  #0);
    fillChar(leakCallStackArray, sizeOf(leakCallStackArray), #0);
    //
    getMemoryManager(oldMM);
    setMemoryManager(ourMM);
  end;
end;

// --  --
procedure mleaks_stop(produceReport: bool);
var
  i: unsigned;
  j: unsigned;
  pter: unsigned;
  size: unsigned;
  s: aString;
begin
  if (g_isStarted) then begin
    // restore old manager
    setMemoryManager(oldMM);
    //
    logMessage('--- MLeaks detection stopped ---');
    //
    if (produceReport) then begin
      // check for leaks
      logMessage(#13#10'--- MLeaks REPORT ---');
      //
      i := 0;
      while (i < maxLeakEntries) do begin
	//
	if (nil <> leakPointersArray[i]) then begin
	  //
	  pter := unsigned(leakPointersArray[i]);
	  asm
	    push	eax

	    mov		eax, pter
	    //
	    sub		eax, 4
	    mov		eax, [eax]
	    and		eax, $7FFFFFFC
	    sub		eax, 4
	    mov		size, eax

	    pop		eax
	  end;
	  //
	  s := 'TID=' + adjust(int2str(leakCallStackArray[i].r_threadId, 16), 4) + '; ptr=$' + adjust(int2str(pter, 16), 8, '0') + '/' + int2str(size, 10, 3) + ' bytes / Stack: ';
	  //
	  j := 0;
	  while (j < maxCallStackDepth) do begin
	    //
	    if (nil <> leakCallStackArray[i].r_callStack[j]) then begin
	      s := s + ' $' + adjust(int2str(unsigned(leakCallStackArray[i].r_callStack[j]), 16), 8, '0');
	    end
	    else
	      break;
	    //
	    inc(j);
	  end;
	  //
	  logMessage(s);
	end;
	//
	inc(i);
      end;
      //
      logMessage(#13#10'--- MLeaks END OF REPORT ---'#13#10);
    end;
    //
    g_isStarted := false;
  end;
end;

{$ENDIF CHECK_MEMORY_LEAKS }


var
  // --  --
  sa: SECURITY_ATTRIBUTES;
  sd: PSecurityDescriptor;
  bInitalized: bool;

// --  --
function getNullDacl(): PSECURITY_ATTRIBUTES;
begin
  if (not bInitalized) then begin
    //
    // create a section with a NULL DACL
    InitializeSecurityDescriptor(sd, SECURITY_DESCRIPTOR_REVISION);
    //
    SetSecurityDescriptorDacl(sd, TRUE, nil, FALSE);
    SetSecurityDescriptorSacl(sd, TRUE, nil, FALSE);
    //
    sa.nLength := sizeOf(sa);
    sa.lpSecurityDescriptor := sd;
    sa.bInheritHandle := FALSE;
    //
    bInitalized := true;
  end;
  //
  result := @sa;
end;


// --  --
{$IFDEF VC25_OVERLAPPED }
var
  i: unsigned;
{$ENDIF VC25_OVERLAPPED }

initialization

{$IFDEF UNAUTILS_MEM_USE_HEAP_CALLS }
  g_heap := HeapCreate(0, 0, 0);
{$ENDIF UNAUTILS_MEM_USE_HEAP_CALLS }

{$IFDEF UNAUTILS_DEBUG_MEM }
  InitializeCriticalSection(g_memLock);
{$ENDIF UNAUTILS_DEBUG_MEM }
  //
  hrpc_query();	// init HRPC vars

  // see if we should use "wide" versions of API
  getOSFeatures();

{$IFDEF CONSOLE_IO }
  // for console applications we will try to open console I/O handlers
  if (g_wideApiSupported) then begin
    //
    g_CONIN  := CreateFileW('CONIN$',  GENERIC_READ,  FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
    g_CONOUT := CreateFileW('CONOUT$', GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
  end
  else begin
    //
    g_CONIN  := CreateFileA('CONIN$',  GENERIC_READ,  FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
    g_CONOUT := CreateFileA('CONOUT$', GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
  end;
  //
{$ENDIF CONSOLE_IO }

  //
{$IFDEF DEBUG }
  setInfoMessageMode('', nil, {$IFDEF CONSOLE }-1{$ELSE }0{$ENDIF }, 1);
{$ELSE }
  setInfoMessageMode('<none>', nil, {$IFDEF CONSOLE }1{$ELSE }0{$ENDIF CONSOLE }, 0);
{$ENDIF DEBUG }
  //
  {$IFDEF LOG_UNAUTILS_INFOS }
  logMessage('unaUtils - DEBUG is defined');
  //
  logMessage(#13#10'unaUtils - >> initializing >>');
  {$ENDIF LOG_UNAUTILS_INFOS }

  //
{$IFDEF CHECK_MEMORY_LEAKS }
  mleaks_start(300);
  {$IFDEF LOG_UNAUTILS_INFOS }
  logMessage('unaUtils - memory leaks check is enabled.');
  {$ENDIF LOG_UNAUTILS_INFOS }
{$ENDIF CHECK_MEMORY_LEAKS }

{$IFDEF UNA_PROFILE }
  profId_unaUtils_base64encode := profileMarkRegister('unaUtils.base64encode()');
  profId_unaUtils_base64decode := profileMarkRegister('unaUtils.base64decode()');
  {$IFDEF LOG_UNAUTILS_INFOS }
  logMessage('unaUtils - profiling is enabled.');
  {$ENDIF LOG_UNAUTILS_INFOS }
{$ENDIF UNA_PROFILE }

{$IFDEF __SYSUTILS_H_ }
  //
  {$IFDEF HOOK_EXCEPTIONS_ALWAYS }
    setExceptionHandler();
    assert(setAssertionHandler());
  {$ENDIF HOOK_EXCEPTIONS_ALWAYS }
  //
  {$IFDEF LOG_UNAUTILS_INFOS }
  logMessage('unaUtils - assuming SysUtils.pas is linked.');
  {$ENDIF LOG_UNAUTILS_INFOS }
{$ELSE }
  //
  setExceptionHandler();
  assert(setAssertionHandler());
  //
  {$IFDEF LOG_UNAUTILS_INFOS }
  logMessage('unaUtils - assuming SysUtils.pas is NOT linked.');
  {$ENDIF LOG_UNAUTILS_INFOS }

{$ENDIF __SYSUTILS_H_ }

  //
  fillLocale();

// --  --
finalization
  //
{$IFDEF LOG_UNAUTILS_INFOS }
  logMessage(#13#10'unaUtils - << finalizing <<');
{$ENDIF LOG_UNAUTILS_INFOS }
  //
{$IFDEF CHECK_MEMORY_LEAKS }
  mleaks_stop();
  //
  {$IFDEF VC25_OVERLAPPED }
  logMessage('mleaks_stop() may report some "leaks", since some of unaUtils.OL buffers are not yet released');
  {$ENDIF VC25_OVERLAPPED }
  //
{$ENDIF CHECK_MEMORY_LEAKS }
  //
  g_unaUtilsFinalized := true;
  //
{$IFDEF __SYSUTILS_H_ }
  {$IFDEF HOOK_EXCEPTIONS_ALWAYS }
  doneExceptionAssertionHandlers();
  {$ENDIF HOOK_EXCEPTIONS_ALWAYS }
{$ELSE }
  doneExceptionAssertionHandlers();
{$ENDIF __SYSUTILS_H_ }
  //
  g_infoLogFileNameW := '';
  if (INVALID_HANDLE_VALUE <> g_infoLogFileHandle) then begin
    //
    closeHandle(g_infoLogFileHandle);
    g_infoLogFileHandle := INVALID_HANDLE_VALUE
  end;
  //
  {$IFDEF VC25_OVERLAPPED }
  if (0 < g_logOLCount) then begin
    //
    WaitForMultipleObjects(g_logOLCount, PWOHandleArray(@g_logOLEvents), true, 3000);
    //
    i := 0;
    while (i < g_logOLCount) do begin
      //
      CloseHandle(g_logOLEvents[i]);
      //mrealloc(g_logOLBufs[i]);
      //
      inc(i);
    end;
    g_logOLCount := 0;
    //
  end;
  {$ENDIF VC25_OVERLAPPED }

{$IFDEF CONSOLE_IO }
  // for console applications we will close console I/O handles
  if (INVALID_HANDLE_VALUE <> g_CONIN) then
    CloseHandle(g_CONIN);
    //
  if (INVALID_HANDLE_VALUE <> g_CONOUT) then
    CloseHandle(g_CONOUT);
  //
{$ENDIF CONSOLE_IO }

{$IFDEF UNAUTILS_DEBUG_MEM }
  DeleteCriticalSection(g_memLock);
{$ENDIF UNAUTILS_DEBUG_MEM }
  //
{$IFDEF UNAUTILS_MEM_USE_HEAP_CALLS }
  HeapDestroy(g_heap);
  g_heap := INVALID_HANDLE_VALUE;
{$ENDIF UNAUTILS_MEM_USE_HEAP_CALLS }
end.


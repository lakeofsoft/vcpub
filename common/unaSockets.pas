
(*
	----------------------------------------------

	  unaSockets.pas
	  Windows sockets wrapper classes (Select model)

	----------------------------------------------
	  Copyright (c) 2001-2010 Lake of Soft
		     All rights reserved

	  http://lakeofsoft.com/
	----------------------------------------------

	  created by:
		Lake, ?? 2001

	  modified by:
		Lake, Jan-Dec 2002
		Lake, Jan-Oct 2003
		Lake, Jan-Dec 2004
		Lake, Jan-Sep 2005
		Lake, Feb-Dec 2006
		Lake, Apr-Dec 2007
		Lake, Jan-Dec 2008
		Lake, Jan-May 2009
		Lake, Feb-Jul 2010

	----------------------------------------------
*)

{$I unaDef.inc }

{$IFDEF DEBUG }
  {$DEFINE LOG_UNASOCKETS_INFOS }	// log informational messages
  {$DEFINE LOG_UNASOCKETS_ERRORS }	// log critical errors
  //
  {xx $DEFINE LOG_RAW_DATA_PACKETS }	// define to log data packets received over network
  {xx $DEFINE LOG_RAW_DATA_PACKETS2 }	// additional data logging
  {xx $DEFINE LOG_SOCKS_THREADS }	// define to log data packets received over network
{$ENDIF DEBUG }

{$IFDEF VC25_OVERLAPPED }
  //
  {$IFNDEF VC25_WINSOCK20 }
  VC25_WINSOCK20 symbol must be defined, since VC25_OVERLAPPED is defined
  {$ENDIF VC25_WINSOCK20  }
  //
{$ENDIF VC25_OVERLAPPED }

{*
  Contains Windows sockets version 1.1 wrapper classes.

  @Author Lake
  @Version 2.5.2008.02 IOCP and WinSock 2.0 extentions
}


unit
  unaSockets;

interface

uses
  Windows, unaTypes, unaClasses,
  WinSock, WinInet
{$IFDEF __SYSUTILS_H_ }
  , SysUtils
{$ENDIF __SYSUTILS_H_ }
  ;

const
{$IFDEF __BEFORE_D6__ }
  //
  {$EXTERNALSYM SD_BOTH }
  SD_BOTH        	= 2;	/// missing in Delphi 5 or earlier
{$ENDIF __BEFORE_D6__ }

  {$EXTERNALSYM SO_MAX_MSG_SIZE }
  SO_MAX_MSG_SIZE	= $2003;		/// maximum message size
  //
  c_defUdpConnTimeout 	= 60000 * 3;		/// default timeout for sockets "connected" to UDP server is 3 minutes

var
  //
  c_maxThreadPoolSize: unsigned	= 256;			/// maximum number of threads in pool

type
  //psockaddr = ^sockaddr;
  sockaddr = packed record
    r_family: uint16;
    r_port: uint16;
    r_addr: uint32;
    r_zero: array [0..7] of aChar;
  end;

  //
  // -- unaWSA --
  //
  {*
	Windows sockets manager class.
  }
  unaWSA = class(unaObject)
  private
    f_data: tWSAData;
    f_status: int;
    f_gate: unaInProcessGate;
  public
    {*
	Creates and initializes internal structures. If active = true (default) startups the Windows Sockets as well.

	@param active Startup Windows sockets (default is True).
	@param version Required WinSock version (default is $0101).
    }
    constructor create(active: bool = true; version: uint32 = $0101);
    {*
	Shuts down Windows sockets if they were started.
    }
    destructor Destroy(); override;
    {*
      Startups the Windows sockets.

      @param version Expected sockets version number.
    }
    function startup(version: uint32 = $0101): int;
    {*
      Cleanups the Windows sockets.
    }
    function shutdown(): int;
    {*
	Returns last status of startup().

	@return 0 - OK, or
	@return WSASYSNOTREADY, WSAVERNOTSUPPORTED, WSAEINPROGRESS, WSAEPROCLIM, WSAEFAULT, ...
    }
    function getStatus(): int;
    {*
	Returns True if getStatus() = 0.

	@return True if Windows sockets were started up successfully.
    }
    function isActive(): bool;
  end;


  {*
    Base class implementing Windows socket.
  }
  unaSocket = class(unaObject)
  private
    f_socket: tSocket;
    f_addressFamily: int;	// AF_INET/AF_NETBIOS/AF_INET6/AF_IRDA/AF_BTM, etc.
    f_socketProtocol: int;	// IPPROTO_TCP/IPPROTO_UDP/IPPROTO_RM, etc.
    f_socketType: int;		// SOCK_STREAM/SOCK_DGRAM/SOCK_RAW/SOCK_RDM/SOCK_SEQPACKET, etc.
    f_host: string;
    //
    {$IFDEF VC25_OVERLAPPED }
    f_overlapped: bool;
    {$ENDIF VC25_OVERLAPPED }
    //
    f_bindToIP: string;
    f_bindToPort: protoEnt;
    //
    f_MTUValid: bool;
    f_MTU: unsigned;
    //
    f_port: protoEnt;
    //
    function socket(): int;
    function check_read(timeout: uint32 = 0): bool;
    function check_write(timeout: uint32 = 0): bool;
    //
    function getIsActive(): bool;
    function getBufSize(index: int): unsigned;
    procedure setBufSize(index: int; value: unsigned);
    //
    procedure setBindToPort(const value: string);
    function getBindToPort(): string;
  protected
    {*
	Closes the socket.

	@return 0 if successfull (or socket was not created), or specific WSA error.
    }
    function closeSocket(): int; virtual;
    {*
	Binds a socket to local address.

	@param addr Local address to bind to.

	@return 0 if successfull, or specific WSA error.
    }
    function bind(addr: pSockAddrIn = nil): int; virtual;
    {*
	Issues an IOCTL command on a socket.

	@param command IOCTL command.
	@param param [IN/OUT] Command param.

	@return 0 if successfull, or specific WSA error.
    }
    function ioctl(command: unsigned; var param: int): int; virtual;
  public
    {*
      Initializes the socket.

      @param overlapped Create overlapped socket (default is True).
    }
    constructor create({$IFDEF VC25_OVERLAPPED }overlapped: bool = true{$ENDIF }); overload;
    {*
      Initializes the socket.
      This constructor is mostly used by TCP server with sockets handle returned by accept().

      @param socket Windows socket handle to assign to socket object.
      @param addressFamily Address family (AF_INET/AF_NETBIOS/AF_INET6/AF_IRDA/AF_BTM, etc).
      @param socketProtocol Proto (IPPROTO_TCP/IPPROTO_UDP/IPPROTO_RM, etc).
      @param socketType Socket type (SOCK_STREAM/SOCK_DGRAM/SOCK_RAW/SOCK_RDM/SOCK_SEQPACKET, etc).
      @param addr Remote address.
      @param len Size of remote address.
    }
    constructor create(socket: tSocket; addressFamily, socketProtocol, socketType: int; const addr: sockaddr_in; len: int); overload;
    {*
	Closes and destroys the socket.
    }
    destructor Destroy(); override;
    {*
	Returns socket handle.

	@param forceCreate Forces socket creation when true (default is False).

	@return Socket handle (or INVALID_SOCKET if socket was not created or was closed and forceCreate is False).
    }
    function getSocket(forceCreate: bool = false): tSocket;
    {*
	Returns sockaddr_in structure filled with address:port values which corresponds to the socket.

	@param addr [OUT] Address record.

	@return 0 if successfull, or a specific WSA error.
    }
    function getSockAddr(out addr: sockaddr_in): int;
    {*
	Returns sockaddr_in structure filled with address:port values which corresponds to the bound socket.
	Do not use if socket is not bound yet.

	@param addr [OUT] Address record.

	@return 0 if successfull, or a specific WSA error.
    }
    function getSockAddrBound(out addr: sockaddr_in): int;
    //
    {*
	Binds the socket to specified port and starts listening for incoming connections.

	@param backlog Number of pending client connections (default is SOMAXCONN).

	@return 0 if successfull (or socket is already listening), or specific WSA error.
    }
    function listen(backlog: int = SOMAXCONN): int;
    {*
	Connects the socket to remote host.

	@param addr Host/port/proto to connect to. If nil (default) own host/port/proto properties will be used instead.

	@return 0 if socket has been connected successfully or specific WSA error.
    }
    function connect(addr: pSockAddrIn = nil): int;
    {*
	Closes the socket.

	@param graceful If True, socket will gracefully close all operations, and then disconnect (default is True).

	@return 0 if successfull (or socket was not connected/listening), or specific WSA error.
    }
    function close(graceful: bool = true): int;
    {*
	Blocks until new connection will be established with socket, or timeout value expires.
	<BR /><STRONG>NOTE</STRONG>: this method should be used with TCP sockets only.

	@param socket [OUT] New socket handle.
	@param timeout Timeout for operation.

	@return New connected client socket, or nil if timeout or error occur.
    }
    function accept(out socket: tSocket; timeout: unsigned = Windows.INFINITE): unaSocket;
    {*
	Shuts down the socket.
	Call close() to clean up the socket before reusing it again.

	@param how One of the following: SD_RECEIVE/SD_SEND/SD_BOTH.

	@return 0 if successfull (or socket was not connected/listening), or specific WSA error.
    }
    function shutdown(how: int): int;
    {*
	Checks if socket is connected.

	@param timeout Timeout in milliseconds.

	@return True if socket is connected to remote host, and there was no error.
    }
    function isConnected(timeout: unsigned = 0): bool;
    {*
	Checks if socket is listening.

	@param timeout Timeout in milliseconds.

	@return True if socket is listening, and there was no error.
    }
    function isListening(): bool;
    {*
	Checks if it is OK to read data from socket now.

	@param timeout Timeout in milliseconds (default is 0, ignored if noCheckState is True).
	@param noCheckState Do not check the state of socket (default is False).

	@return True if there are some chances data could be read now.
    }
    function okToRead(timeout: unsigned = 0; noCheckState: bool = false): bool;
    {*
	Checks if it is OK to write data into socket now.

	@param timeout Timeout in milliseconds (default is 0, ignored if noCheckState is True).
	@param noCheckState Do not check the state of socket (default is False).

	@return True if there are some chances data could be send now.
    }
    function okToWrite(timeout: unsigned = 0; noCheckState: bool = false): bool;
    {*
	Checks if there is some error with socket.

	@param timeout Timeout in milliseconds (default is 0).

	@return True if there are some error.
    }
    function check_error(timeout: uint32 = 0): bool;
    //
    {*
	Reads data from socket.

	@param buf Data buffer.
	@param size [IN/OUT] Size of buffer, how many bytes to read. On success specifies how many bytes were actually read.
	@param timeout Timeout in milliseconds (default is INFINITE).
	@param noCheck Do not check the state of socket (default is False).

	@return -1, if socket is not connected or no data were available within timeout period.
	@return 0, if data was read, and size specifies actual amount of data read.
	@return Otherwise returns some specific WSA error.
    }
    function read(const buf: pointer; var size: unsigned; timeout: unsigned = Windows.INFINITE; noCheck: bool = false): int;
    {*
	Reads a string from socket.
    }
    function readString(noCheck: bool = false): aString;
    {*
	Waits until data will be available to read from socket or timeout expire.
    }
    function waitForData(timeout: unsigned = Windows.INFINITE; noCheckState: bool = false): bool;
    {*
	Returns number of bytes available to read from socket.
    }
    function getPendingDataSize(noCheckState: bool = false): unsigned;
    {*
	Sends data over socket.

	@param buf Pointer to data buffer.
	@param size Size of buffer.
	@param noCheck Do not check socket's state if True. Default if False.

	@return -1 if socket cannot send now, -2 if number of bytes send is different from len,
	@return 0 if sent operation was OK, or specific WSA error.
    }
    function send(buf: pointer; size: unsigned; noCheck: bool = false): int; overload;
    {*
	Sends string of bytes over socket.

	@param value String of bytes to be sent.
	@param noCheck Do not check socket's state if True. Default if False.

	@return -1 if socket cannot send now, -2 if number of bytes send is different from len,
	@return 0 if sent operation done was OK, or specific WSA error.
    }
    function send(const value: aString; noCheck: bool = false): int; overload;
    //
    {*
      Returns boolean option of the socket.
    }
    function getOptBool(opt: int): bool;
    {*
      Returns integer option of the socket.
    }
    function getOptInt(opt: int): int;
    {*
      Sets boolean option of the socket.
    }
    function setOptBool(opt: int; value: bool): int;
    {*
      Sets integer option of the socket.
    }
    function setOptInt(opt: int; value: int): int;
    {*
      Sets remote host address/DNS name. Does nothing if socket is active (connected/listening).
    }
    procedure setHost(const host: string);
    {*
      Sets remote port number for the socket. This value will be used to connect socket to.
    }
    function setPort(const port: string; noCheck: bool = false): bool; overload;
    {*
      Sets remote port number for the socket. This value will be used to connect socket to.
    }
    function setPort(port: word; noCheck: bool = false): bool; overload;
    {*
      Returns remote port value as string.
    }
    function getPort(): string;
    {*
      Returns remote port value as word.
    }
    function getPortInt(): word;
    {*
      Returns maximum transmission unit (MTU) size.
      <BR /><STRONG>NOTE</STRONG>: this value should not be used as real MTU size, but only as an estimation for most cases.
    }
    class function getGeneralMTU(): unsigned;
    {*
      Returns maximum transmission unit (MTU) size for connected socket.
    }
    function getMTU(): unsigned;
    {*
      Binds the socket to specified port.
      If port value is -1 (default), this function uses the bindToPort property as a port number to bind to.
      If port value is 0, this function auto-assigns first available port number for socket.

	@return 0 if successfull (or socket is not connected/listening), or specific WSA error.
    }
    function bindSocketToPort(port: int = -1): int;
    //
    // -- properties --
    //
    {*
	Socket handle.
    }
    property handle: tSocket read f_socket;
    {*
      Specifies remote host value for the socket. This value will be used to connect socket to.
    }
    property host: string read f_host write setHost;
    {*
      Specifies socket address family. For most applications you should use the AF_INET value.
      Other possible values: AF_INET/AF_NETBIOS/AF_INET6/AF_IRDA/AF_BTM
    }
    property addressFamily: int read f_addressFamily;
    {*
      Specifies protocol number to be used with socket.
      Here is the list of most common values for the protocol although many other values are possible:
      <UL>
	<LI>IPPROTO_TCP - tcp</LI>
	<LI>IPPROTO_UDP - user datagram protocol</LI>
	<LI>IPPROTO_RM - The PGM protocol for reliable multicast</LI>
      </UL>
    }
    property socketProtocol: int read f_socketProtocol;
    {*
      Specifies socket type to be used with socket. Following values are defined:
      <UL>
	<LI>SOCK_STREAM - stream socket
	<LI>SOCK_DGRAM - datagram socket
	<LI>SOCK_RAW - raw-protocol interface
      </UL>
      Other values are also defined in WinSock.pas
    }
    property socketType: int read f_socketType;
    {*
      Specifies IP address the socket should bind to.
      Default value means the socket will bind to any availabe interface.
    }
    property bindToIP: string read f_bindToIP write f_bindToIP;
    {*
      Specifies Port name or number the socket should bind to.
      Default value (0) means the socket will bind to first availabe port number.
      Client sockets should always be bind to default port (0), unless you need some special behaviour.
    }
    property bindToPort: string read getBindToPort write setBindToPort;
    {*
      Returns True is socket is TCP server socket and is listening,
      or if socket is TCP client and is connected, or if socket is bind to UDP port/interface.
      Otherwise returns false.
    }
    property isActive: bool read getIsActive;
    {*
      Size of sending buffer.
    }
    property sndBufSize: unsigned index 0 read getBufSize write setBufSize;
    {*
      Size of receiving buffer.
    }
    property rcvBufSize: unsigned index 1 read getBufSize write setBufSize;
  end;


  //
  // -- unaTcpSocket --
  //
  {*
    This class encapsulates TCP socket implementation.
  }
  unaTcpSocket = class(unaSocket)
  private
  public
    {*
      Creates TCP socket.
    }
    constructor create({$IFDEF VC25_OVERLAPPED }overlapped: bool = true{$ENDIF });
    {*
      Binds a socket to specified in bindToIP and bindToPort interface and port (or default, if not specified).
    }
    function doBind(addr: pSockAddrIn = nil): int;
  end;


  //
  // -- unaUdpSocket --
  //
  {*
    This class encapsulates UDP socket implementation.
  }
  unaUdpSocket = class(unaSocket)
  private
  public
    {*
      Creates UDP socket.
    }
    constructor create({$IFDEF VC25_OVERLAPPED }overlapped: bool = true{$ENDIF VC25_OVERLAPPED });
    //
    {*
      Receives data from remote host. Flags could be 0, MSG_PEEK or MSG_OOB.
      <BR />Returns 0 if data was received successfully, in which case from parameter will contain remote address data was sent from.
      <BR />Returns specific WSA error otherwise.
    }
    function recvfrom(out from: sockaddr_in; var data: aString; noCheck: bool = true; flags: unsigned = 0; timeout: unsigned = 3000): int; overload;
    {*
      Receives data from remote host. Flags could be 0, MSG_PEEK or MSG_OOB.
      <BR />NOTE: Memory block pointed by data must be large enough to receive up to MTU bytes.
      <BR />Returns size of data if it was received successfully, in which case from parameter will contain remote address data was sent from.
      <BR />Returns 0 if the connection has been gracefully closed.
      <BR />Returns SOCKET_ERROR if some error ocurred, or -2 if no data can be read at this time.
    }
    function recvfrom(out from: sockaddr_in; data: pointer; dataLen: unsigned; noCheck: bool = true; flags: unsigned = 0; timeout: unsigned = 3000): int; overload;
    {*
      Sends string of data to remote host. Flags could be 0, MSG_DONTROUTE or MSG_OOB.
      <BR />Returns 0 if data was sent successfully, or specific WSA error otherwise.
    }
    function sendto(var addr: sockaddr_in; const data: aString; flags: unsigned = 0; timeout: unsigned = 3000): unsigned; overload;
    {*
      Sends string of data to remote host. Flags could be 0, MSG_DONTROUTE or MSG_OOB.
      <BR />If noCheck parameter is true it will not check the socket state before sending the data. This could be used to avoid unnecessary delays.
      <BR />Returns 0 if data was sent successfully, or specific WSA error otherwise.
    }
    function sendto(var addr: sockaddr_in; const data: aString; noCheck: bool = true; flags: unsigned = 0): unsigned; overload;
    {*
      Sends block of data to remote host. Flags could be 0, MSG_DONTROUTE or MSG_OOB.
      <BR />If noCheck parameter is true it will not check the socket state before sending the data. This could be used to avoid unnecessary delays.
      <BR />Returns 0 if data was sent successfully, or specific WSA error otherwise.
    }
    function sendto(var addr: sockaddr_in; data: pointer; size: unsigned; flags: unsigned = 0; timeout: unsigned = 3000; noCheck: bool = false): unsigned; overload;
    {*
      Sends block of data to remote host. Flags could be 0, MSG_DONTROUTE or MSG_OOB.
      <BR />If noCheck parameter is true it will not check the socket state before sending the data. This could be used to avoid unnecessary delays.
      <BR />Returns 0 if data was sent successfully, or specific WSA error otherwise.
    }
    function sendto(var addr: sockaddr_in; data: pointer; size: unsigned; noCheck: bool = true; flags: unsigned = 0): unsigned; overload;
    {*
      Binds a socket to specified in bindToIP and bindToPort interface and port (or default, if not specified).
    }
    function doBind(addr: pSockAddrIn = nil): int;
  end;



const

// NOTE: WinSock.pas (up to Delphi 2005) contains definitions of older values for IP_XXX constants

(*
 * The following constants are taken from include/netinet/in.h
 * in Berkeley Software Distribution version 4.4. Note that these
 * values *DIFFER* from the original values defined by Steve Deering
 * as described in "IP Multicast Extensions for 4.3BSD UNIX related
 * systems (MULTICAST 1.2 Release)". It describes the extensions
 * to BSD, SunOS and Ultrix to support multicasting, as specified
 * by RFC-1112.

 http://www.sockets.com/wsnp.htm
 *)

{$EXTERNALSYM IP_MULTICAST_IF }
{$EXTERNALSYM IP_MULTICAST_TTL }
{$EXTERNALSYM IP_MULTICAST_LOOP }
{$EXTERNALSYM IP_ADD_MEMBERSHIP }
{$EXTERNALSYM IP_DROP_MEMBERSHIP }
//
{$EXTERNALSYM IP_DEFAULT_MULTICAST_TTL }
{$EXTERNALSYM IP_DEFAULT_MULTICAST_LOOP }
{$EXTERNALSYM IP_MAX_MEMBERSHIPS }

  IP_MULTICAST_IF	= 9;  //* set/get - IP multicast interface */
  IP_MULTICAST_TTL	= 10; //* set/get - IP multicast TTL */
  IP_MULTICAST_LOOP	= 11; //* set/get - IP multicast loopback */
  IP_ADD_MEMBERSHIP	= 12; //* set     - add IP group membership */
  IP_DROP_MEMBERSHIP	= 13; //* set     - drop IP group membership */
  //
  IP_DEFAULT_MULTICAST_TTL	= 1;
  IP_DEFAULT_MULTICAST_LOOP	= 1;
  IP_MAX_MEMBERSHIPS		= 20;

type
  //
  // -- ip_mreq --
  //
  ip_mreq = packed record
    //
    imr_multiaddr: in_addr; //* multicast group to join */
    imr_interface: in_addr; //* interface to join on */
  end;


  //
  // -- unaMulticastSocket --
  //
  unaMulticastSocket = class(unaUdpSocket)
  private
    f_loopDisableForce: bool;
    f_isReadySender: bool;
    f_isReadyReceiver: bool;
    //
    f_senderAddr: sockaddr_in;	// cache for faster sending
    //
    f_recLastGroup: string;
    f_recGroupCount: int;
    //
  protected
    function closeSocket(): int; override;
  public
    {*
      Creates a mulicast sender with specified parameters.
      If noBind is false (default) it also binds a socket to interface specified
      in bindToIP property (or to default interface if bindToIP is '0.0.0.0').
      Returns 0 for success, or socket-specific error code otherwise.
    }
    function senderCreate(ttl: DWORD = IP_DEFAULT_MULTICAST_TTL; enableLoop: DWORD = 0; noBind: bool = true): int;
    {*
      Sends a multicast packet to a grop specified by host and port properties.
      Returns 0 for success, or socket-specific error code otherwise.
    }
    function senderSend(data: pointer; len: int; noCheck: bool = false): int; overload;
    function senderSend(const data: aString; noCheck: bool = false): int; overload;
    //
    {*
      Joins the specified group.
      Also binds a socket to port and interface specified by port and bindToIP property
      (or default interface if bindToIP = '0.0.0.0').
      Use recvfrom() to receive multicast packets from a group(s).
      Returns 0 for success, or socket-specific error code otherwise.
    }
    function recGroupJoin(const groupAddr: string): int;
    {*
      Leaves the specified group (or a group it joined in a previous successfull call to recGroupJoin() if groupAddr = '').
      Returns 0 for success, or socket-specific error code otherwise.
    }
    function recGroupDrop(const groupAddr: string = ''): int;
    //
    function isReady(sender: bool = true): bool;
  end;



  //
  // -- unaSocksConnection --
  //
  unaSocksThread = class;

  {*
    This is base class for connection between two sockets.
  }
  unaSocksConnection = class(unaObject)
  private
    f_thread: unaSocksThread;
    f_threadSocket: unaSocket;
    f_addr: sockaddr_in;
    f_connId: unsigned;
    f_destroying: bool;
    //
    f_gate: unaInProcessGate;
    f_lpStamp: int64;
    //
    function getAddr(): pSockAddrIn;
  protected
    function acquire(timeout: unsigned): bool;
    procedure resetTimeout();
    function getTimeout(): unsigned;
    //
    property destroying: bool read f_destroying;
    property threadSocket: unaSocket read f_threadSocket;
  public
    constructor create(thread: unaSocksThread; connId: unsigned; socket: unaSocket; addr: pSockAddrIn = nil; len: int = 0);
    procedure BeforeDestruction(); override;
    //
    {*
      Sends data to remote socket.
      <BR />Returns 0 if data was sent successfully, or specific WSA error otherwise.
    }
    function send(data: pointer; size: unsigned; noCheck: bool = false): unsigned;
    {*
      Returns true if there are some chances data could be sent right now..
    }
    function okToWrite(timeout: unsigned = 100; noCheckState: bool = false): bool;
    {*
      Compares given address with address of local socket.
      <BR />Returns true if given address belongs to local socket.
    }
    function compareAddr(const addr: sockaddr_in): bool;
    //
    procedure release();
    //
    {*
      Returns local socket class instance.
    }
    property socket: unaSocket read f_threadSocket;
    {*
      Returns pointer to sockaddr_in structure filled by local socket.
    }
    property paddr: pSockAddrIn read getAddr;
    {*
      id of this connection.
    }
    property connId: unsigned read f_connId;
  end;


  //
  // -- unaSocketsConnections --
  //

  unaSocketsConnections = class(unaIdList)
  protected
    function getId(item: pointer): int64; override;
  public
    function get_connection(connId: unsigned; timeout: unsigned = 2000): unaSocksConnection;
  end;


  //
  //
  unaSocks = class;

  //
  // -- unaSocksThread --
  //
  {*
    This thread is used to handle server or client connections.
  }
  unaSocksThread = class(unaThread)
  private
    f_id: unsigned;
    f_udpConnectionTimeout: unsigned;
    f_backlog: int;
    f_isServer: bool;
    f_lastConnectionIdInt: int;
    f_socks: unaSocks;
    f_socketError: integer;
    //
    f_socket: unaSocket;
    f_initDone: unaEvent;
    f_connections: unaSocketsConnections;
    f_psThread: unaThread;
    //
    procedure onConnectionRemove(connId: unsigned);
  protected
    function execute(globalIndex: unsigned): int; override;
    function getConnectionByAddr(const addr: sockaddr_in; needAcquire: bool): unaSocksConnection;
    function checkSocketError(errorCode: integer; addr: pSockAddrIn = nil; allowThreadStop: bool = true): bool;
    function newConnId(initialValue_delta: int = -1): unsigned;
    procedure releaseSocket();
    //
    function sendDataTo(connId: unsigned; data: pointer; len: unsigned; out asynch: bool; timeout: unsigned = 500): int; virtual;
    function doGetRemoteHostAddr(connId: unsigned): pSockAddrIn; virtual;
  public
    constructor create(socks: unaSocks; id: unsigned);
    procedure BeforeDestruction(); override;
    destructor Destroy(); override;
    {*
      Returns sockets connection for specified connection id.
    }
    function getConnection(connId: unsigned; timeout: unsigned = 2000): unaSocksConnection;
    function getRemoteHostAddr(connId: unsigned): pSockAddrIn;
    //
    property id: unsigned read f_id;
    property udpConnectionTimeout: unsigned read f_udpConnectionTimeout;
    property backLog: int read f_backLog;
    property threadSocket: unaSocket read f_socket;
    property socketError: integer read f_socketError;
    property isServer: bool read f_isServer;
    //
    property socks: unaSocks read f_socks;
    property initDone: unaEvent read f_initDone;
    property connections: unaSocketsConnections read f_connections;
  end;


  //
  // -- unaSocketsThreads --
  //
  unaSocksThreads = class(unaIdList)
  protected
    function getId(item: pointer): int64; override;
  public
  end;


  {*
	Different events produced by unaSocks class.

    <PRE>
    unaseServerListen 		- SERVER: server was started
    unaseServerStop		- SERVER: server was stopped
    unaseServerConnect		- SERVER: new client was connected to server
    unaseServerData		- SERVER: new data was received from client
    unaseServerDisconnect	- SERVER: client was disconnected from server (by timeout or socket error for UDP)

    <BR>unaseClientConnect		- CLIENT: client was connected
    unaseClientData		- CLIENT: new data was received from server
    unaseClientDisconnect	- CLIENT: client was disconnected from server

    <BR>unaseThreadStartupError	- SERVER: server could not start
				- CLIENT: client could not connect to server

    <BR>unaseThreadAdjustSocketOptions	- SERVER: adjust socket options created by server (connId is tSocket, data <> nil means "main" socket)
					- CLIENT: adjust socket options created by client (connId is tSocket, data <> nil means "main" socket)
    </PRE>

  }
  unaSocketEvent = (
    // server
    unaseServerListen,
    unaseServerStop,
    unaseServerConnect,
    unaseServerData,
    unaseServerDisconnect,
    // client
    unaseClientConnect,
    unaseClientData,
    unaseClientDisconnect,
    // thread
    unaseThreadStartupError,
    unaseThreadAdjustSocketOptions
  );

  /// Socks event handler type
  unaSocksOnEventEvent = procedure(sender: tObject; event: unaSocketEvent; id, connId: unsigned; data: pointer; size: unsigned) of object;

  {*
    This class is used to create server and client sockets and manage the connections.
  }
  unaSocks = class(unaObject)
  private
    f_master: bool;
    f_threadPoolSize: unsigned;
    f_lastThreadID: int;
    //
    {$IFDEF VC25_IOCP }
    f_isIOCP: bool;
    f_isRTP: bool;
    {$ENDIF VC25_IOCP }
    //
    f_gate: unaInProcessGate;
    f_threads: unaSocksThreads;
    f_onEvent: unaSocksOnEventEvent;
    //
    function createSocket(protocol: int {$IFDEF VC25_OVERLAPPED }; overlapped: bool = true{$ENDIF }): unaSocket;
    function getThreadByIndex(index: unsigned): unaSocksThread;
    function getThreadFromPool(allowGrowUp: bool = true): unaSocksThread;
    //
    {$IFDEF VC25_IOCP }
    procedure setIsIOCP(value: bool);
    procedure setIsRTP(value: bool);
    //
    procedure recreateThreadsPool();
    {$ENDIF VC25_IOCP }
  protected
    {*
	This virtual method is called every time new sockets event occur.

	@param id Specifies the thread id for which the even applies.
	@param connId Specifies the connection id of the thread for which the even applies.
	@param event Specifies the type of event (see <A href="../unaSocketEvent.htm">unaSocketEvent</A> for details).
	@param data Data block available from client or server.
	@param size Size of data.
    }
    procedure event(event: unaSocketEvent; id, connId: unsigned; data: pointer = nil; size: unsigned = 0); virtual;
  public
    {*
	Creates socks object.

	@param threadsInPool Number of threads to create in pool (default is 4).
	@param isIOCP Use IOCP for sockets' operations (default is False).
    }
    constructor create(threadsInPool: unsigned = 4 {$IFDEF VC25_IOCP }; isIOCP: bool = false{$ENDIF VC25_IOCP });
    {*
	Destroys socks object.
    }
    destructor Destroy(); override;
    {*
	Locks socks object.

	@param timeout Timeout (default is INFINITE).
    }
    function enter(timeout: unsigned = INFINITE): bool;
    {*
	Unlocks socks object.
    }
    procedure leave();
    {*
	Sets new pool size.

	@param threadsInPool Specifies the number of threads in the pool to be created.
    }
    procedure setPoolSize(threadsInPool: unsigned);
    {*
	Creates new client socket.
	Returns thread id which will handle events for this client connection or 0 if some error occured.

	@param host Remote host to connect to.
	@param port Remote port to connect to.
	@param protocol Proto (UDP or TCP, default is IPPROTO_TCP).
	@param activate Connect client after creation (default is True).
	@param bindToIP Bind to this local IP (default is '0.0.0.0').
	@param bindToPort Bind to this local port (default is '0').
	@param overlapped Create overlapped socket (default is True).

	@return Thread id or 0 if some error occured.
    }
    function createConnection(const host, port: string; protocol: int = IPPROTO_TCP; activate: bool = true; const bindToIP: string = '0.0.0.0'; const bindToPort: string = '0' {$IFDEF VC25_OVERLAPPED }; overlapped: bool = true{$ENDIF }): unsigned;
    {*
	Creates new server socket.
	Returns thread id which will handle connections for this socket or 0 if some error occur.

	@param port Local port to listen at.
	@param protocol Proto (UDP or TCP, default is IPPROTO_TCP).
	@param activate Start server after creation (default is True).
	@param backlog Number of pending client connections (default is SOMAXCONN).
	@param udpConnectionTimeout Timeout for UDP clients (default is c_defUdpConnTimeout (3 minutes)).
	@param bindToIP Bind to this local IP (default is '0.0.0.0').
	@param overlapped Create overlapped socket (default is True).

	@return Thread id or 0 if some error occured.
    }
    function createServer(const port: string; protocol: int = IPPROTO_TCP; activate: bool = true; backlog: int = SOMAXCONN; udpConnectionTimeout: unsigned = c_defUdpConnTimeout; const bindToIP: string = '0.0.0.0' {$IFDEF VC25_OVERLAPPED }; overlapped: bool = true{$ENDIF }): unsigned;
    {*
	Activate a thread (start server or connect client).

	@param id Thread id to activate.

	@return True if thread was started successfully.
    }
    function activate(id: unsigned): bool;
    {*
	Returns thread active state.

	@return True if thread is active (server is listening, client is connected).
    }
    function isActive(id: unsigned): bool;
    {*
	Sends data to remote side over specified connection.

	@param id Thread id which handles the connection.
	@param data Data buffer to send.
	@param size Size of data buffer.
	@param connId Client connection id (0 for client threads).
	@param noCheck Do not check the state of connection before sending (speeds up sending a little, default is False).
	@param timeout Timeout in ms for error checking (valid if noCheck is False, default is 1000).

	@return 0 if data was sent successfully, or specific WSA error otherwise.
    }
    function sendData(id: unsigned; data: pointer; size: unsigned; connId: unsigned; out asynch: bool; noCheck: bool = false; timeout: unsigned = 500): unsigned;
    {*
	Returns true if it seems that we can send data to remote side over specified connection.

	@param id Thread id which handles the connection.
	@param connId Client connection id (0 for client threads).
	@param timeout Timeout in ms for error checking (valid if noCheck is False, default is 100).
	@param noCheckState Do not check the state of connection before sending (speeds up sending a little, default is False).

	@return True if data can be send.
    }
    function okToWrite(id, connId: unsigned; timeout: unsigned = 100; noCheckState: bool = false): bool;
    {*
	Returns specified connection.

	@param id Thread id which handles the connection.
	@param connId Client connection id (0 for client threads).
	@param timeout Timeout in ms for acquiring (if needAcquire is True, default is 2000).
	@param needAcquire Lock connection object before returning (default is True).<BR>WARNING! If needAcquire was True (default), you must call .release() method of returned connection when it is no longer needed.

	@return Connection object or nil.
    }
    function getConnection(id: unsigned; connId: unsigned; timeout: unsigned = 2000; needAcquire: bool = true): unaSocksConnection;
    {*
	Returns socket object assigned to a thread.

	@param id Thread id.

	@return Socket object or nil.
    }
    function getThreadSocket(id: unsigned): unaSocket;
    {*
	Closes and removes specified connection.
	If thread has no more connections, closes it as well.

	@param id Thread id which handles the connection.
	@param connId Client connection id (0 for client threads).

	@return True if connection was closed.
    }
    function removeConnection(id: unsigned; connId: unsigned): bool;
    {*
	Returns remote IP and port for connection.

	@param id Thread id which handles the connection.
	@param connId Client connection id (0 for client threads).
	@param ip [OUT] Remote IP.
	@param port [OUT] Remote port.

	@return True if function was successfull.
    }
    function getRemoteHostInfo(id, connId: unsigned; out ip, port: string): bool; overload;
    {*
	Converts address record into IP and port.

	@param addr Address record.
	@param ip [OUT] Remote IP.
	@param port [OUT] Remote port.

	@return True if function was successfull.
    }
    function getRemoteHostInfo(addr: pSockAddrIn; out ip, port: string): bool; overload;
    {*
	Returns remote IP, port and proto for connection.

	@param id Thread id which handles the connection.
	@param connId Client connection id (0 for client threads).
	@param ip [OUT] Remote IP.
	@param port [OUT] Remote port.
	@param proto [OUT] Remote proto (IPPROTO_TCP/IPPROTO_UDP).

	@return True if function was successfull.
    }
    function getRemoteHostInfoEx(id, connId: unsigned; out ip, port: string; out proto: int): bool;
    {*
	Returns remote address for connection.

	@param id Thread id which handles the connection.
	@param connId Client connection id (0 for client threads).

	@return Pointer to address record or nil.
    }
    function getRemoteHostAddr(id, connId: unsigned): pSockAddrIn;
    {*
	Closes and removes all connection for specified thread.
	Also stops the thread and makes it available for new connections.

	@param id Thread id.
	@param timeout Timeout in ms (default is 2700).

	@return True if operation was successfull.
    }
    function closeThread(id: unsigned; timeout: int = 2700): bool;
    {*
	Returns thread object.

	@param id Thread id.

	@return Thread object or nil.
    }
    function getThreadByID(id: unsigned; timeout: unsigned = 1000): unaSocksThread;
    {*
	Returns socket error for a thread.

	@param id Thread id.
	@param needLock Lock the threads (defualt is True).

	@return Error code.
    }
    function getSocketError(id: unsigned; needLock: bool = true): int;
    {*
	Closes all client or server (or both) threads.

	@param clearServers Close all server threads (default is False).
	@param clearClients Close all client threads (default is False).
    }
    procedure clear(clearServers: bool = false; clearClients: bool = false);
    {*
	This event is fired every time new sockets event occurs.
	Refer to .event() method for more information.
    }
    property onEvent: unaSocksOnEventEvent read f_onEvent write f_onEvent;
    //
{$IFDEF VC25_IOCP }
    {*
	Specifies whether IOCP sockets must be used for threads.
    }
    property isIOCP: bool read f_isIOCP write setIsIOCP;
    {*
	Specifies whether threads should be aware of RTP packets.
    }
    property isRTP: bool read f_isRTP write setIsRTP;
{$ENDIF VC25_IOCP }
  end;


// -- internal --
function checkError(value: int; fatal: bool = true {$IFDEF DEBUG}; const caller: string = ''{$ENDIF}): int; {$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }


{*
  Lookups host name.
  <BR />Host name could be in integer ("194.44.186.254") or alpha ("www.microsoft.com") format or "" for local machine.
  <BR />Returns 0 if successful or specific WSA error otherwise.
}
function lookupHost(const host: string): int; overload;

{*
  Lookups host name. If the "list" parameter is not nil, it also lists all addresses assigned to a host.
  <BR />Host name could be in integer ("194.44.186.254") or alpha ("www.microsoft.com") format or "" for local machine..
  <BR />Returns 0 if successful or specific WSA error otherwise.
  <BR />Also fills the given ip string with a string representation of the IP address of the host (if resolved).
}
function lookupHost(const host: string; out ip: string; list: unaStringList = nil): int; overload;

{*
  Lookups host name.
  <BR />Host name could be in integer ("194.44.186.254") or alpha ("www.microsoft.com") format or "" for local machine..
  <BR />If lookup fails, it uses the default parameter value as the IP address of the host.
  <BR />Returns IP address of the host or default parameter value if lookup fails.
}
function lookupHost(const host: string; defValue: unsigned): unsigned; overload;

{*
  Lookups host info.
  <BR />Returns the FQDN of the host (if any).
}
function getHostInfo(ip: uint32): string;

{*
  List all addresses assigned to a host.
  <BR />Host name could be in integer ("194.44.186.254") or alpha ("www.microsoft.com") format or "" for local machine.
  <BR />Returns 0 if successful or specific WSA error otherwise.
}
function listAddresses(const host: string; list: unaStringList): int;

{*
  Lookups port number.
  <BR />Port name could be in integer ("110") or string ("POP3") format.
  <BR />Returns port number if successful, or -1 if port is invalid.
}
function lookupPort(const port: string): int; overload;

{*
  Lookups port number.
  <BR />Port name could be in integer ("110") or string ("POP3") format.
  <BR />Returns 0 if successful, -1 if port is "" or specific WSA error otherwise.
  <BR />Also fills given port_info parameter.
}
function lookupPort(const port: string; out port_info: protoent): int; overload;

{*
  Startups the Windows sockets by creating unaWsa class instance.
}
function startup(version: unsigned = {$IFDEF VC25_WINSOCK20 }$0202{$ELSE }$0101{$ENDIF }): int;

{*
  Shutdowns the Windows sockets by deleting the unaWsa class instance created in startup() routine.
}
function shutdown(): int;

{*
  Returns unaWSA class instance created by a call to startup(), or by unaSocks class.
}
function getWSAObject(): unaWSA;

{*
    Issues select() operation on a socket.

    @param s Socket handle.
    @param r Pointer to a bool value, receiving READ status.
    @param w Pointer to a bool value, receiving WRITE status.
    @param e Pointer to a bool value, receiving ERROR status.
    @param timeout Specifies the amount of time in milliseconds.

    @return 0 if timeout occured, 1 if successfull, or some specific WSA error otherwise.
}
function select(s: tSocket; r, w, e: pbool; timeout: unsigned = INFINITE): int;
{$IFDEF __AFTER_DB__ }
  // for some reason Delphi 2007 and earlier compilers give AV when inline is defined for this function :(
  {$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
{$ENDIF __AFTER_DB__ }

// --  --
{*
  Converts host byte order (little endian) unsigned 32 bits integer to string representing IP address (xxx.xxx.xxx.xxx).
}
function ipH2str(ip: unsigned): string;
{*
  Converts network byte order (big endian) unsigned 32 bits integer to string representing IP address (xxx.xxx.xxx.xxx).
}
function ipN2str(ip: unsigned): string;
{*
  Converts string representing IP address (xxx.xxx.xxx.xxx) into host byte order (little endian) unsigned 32 bits integer.
}
function str2ipH(const ip: string): unsigned;
{*
  Converts string representing IP address (xxx.xxx.xxx.xxx) into network byte order (big endian) unsigned 32 bits integer.
}
function str2ipN(const ip: string): unsigned;
{*

}
function addr2str(addr: pSockAddrIn): string;

{*
	Return True if specified address is whiting multicast range.
}
function isMulticastAddr(const addr: string): bool;
{*
	Return True if specified address is whiting multicast range.
	ip is little-endian.
}
function isMulticastAddrH(ip: DWORD): bool;
{*
	Return True if specified address is whiting multicast range.
	ip is big-endian (in network order).
}
function isMulticastAddrN(ip: DWORD): bool;
{*
	Return True if specified address is whiting broadcast range.
	ip is big-endian (in network order).
}
function isBroadcastAddrN(ip: DWORD): bool;

{*
	Returns True if two addresses are same (has same IP and port).
}
function sameAddr(const addr1, addr2: sockaddr_in): bool;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }

{*
	Returns True if function succeeded.
}
function makeAddr(const host, port: string; var addr: sockaddr_in): bool;{$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }


// -- IP/HTTP --

type
  tIpQueryCallback = procedure(queryId: unsigned; const query: string; const response, responseData: aString) of object;

//
// returns -1 in case of some problem or
// valid queryId (which is an integer greater than 0) if all seems to be OK
function httpQuery(const ip, port, query: string; callback: tIpQueryCallback = nil; timeout: unsigned = 5000): int;
function ipQuery(const ip, port, query: string; proto: int = IPPROTO_TCP; callback: tIpQueryCallback = nil; timeout: unsigned = 5000): int;

type
  // URI crack record
  unaURICrack = packed record
    r_scheme: string;         	/// scheme name
    r_hostName: string;       	/// host name
    r_port: INTERNET_PORT;      /// port
    r_userName: string;      	/// user name
    r_password: string;       	/// password
    r_path: string;        	/// URL-path
    r_extraInfo: string;	/// extra information (e.g. ?foo or #foo)
  end;

{*
	Uses InternetCrackURL(), takes care of unicode/ansi versions
}
function crackURI(const URI: string; var crack: unaURICrack; flags: DWORD = 0): bool;


implementation


uses
  unaUtils
{$IFDEF VC25_WINSOCK20 }
  , unaWSASockets
  {$IFDEF VC25_IOCP }
  , unaIOCPSockets
  {$ENDIF VC25_IOCP }
{$ENDIF VC25_WINSOCK20 }
{$IFDEF VC25_IOCP }
  , unaIOCP
{$ENDIF VC25_IOCP }
  ;

var
  g_unaWSA: unaWSA = nil;
  g_unaWSACount: unsigned = 0;
  g_unaWSAGate: unaInProcessGate = nil;
  g_unaWSAGateReady: bool = false;

// --  --
function startup(version: unsigned): int;
begin
  result := -1;
  //
  if (g_unaWSAGateReady) then begin
    //
    if (g_unaWSAGate.enter(1000)) then begin
      //
      try
	if (nil = g_unaWSA) then
	  g_unaWSA := unaWsa.create(true, version);
	//
	inc(g_unaWSACount);
	result := 0;
	//
      finally
	g_unaWSAGate.leave();
      end;
    end;
    //
  end;
end;

// --  --
function shutdown(): int;
begin
  result := -1;
  //
  if (g_unaWSAGateReady) then begin
    //
    if (g_unaWSAGate.enter(1000)) then begin
      //
      try
	if (0 < g_unaWSACount) then
	  dec(g_unaWSACount)
	else begin
	  //
	  {$IFDEF LOG_UNASOCKETS_ERRORS }
	  logMessage('unaSockets.shutdown() - startup/shutdown calls do not match.');
	  {$ENDIF LOG_UNASOCKETS_ERRORS }
	end;
	//
	if (1 > g_unaWSACount) then
	  freeAndNil(g_unaWSA);
	//
	result := 0;
	//
      finally
	g_unaWSAGate.leave();
      end;
    end;
  end;
end;

// --  --
function getWSAObject(): unaWSA;
begin
  result := g_unaWSA;
end;

// --  --
function checkError(value: int; fatal: bool = true {$IFDEF DEBUG }; const caller: string = ''{$ENDIF DEBUG }): int;
begin
  if (SOCKET_ERROR = value) then begin
    //
    result := WSAGetLastError();
    //
    {$IFDEF LOG_UNASOCKETS_ERRORS }
    if (fatal) then
      logMessage('unaSockets: * socket error in ' + {$IFDEF DEBUG }caller{$ELSE}'()'{$ENDIF DEBUG } + ': ' + int2str(result));
    {$ENDIF LOG_UNASOCKETS_ERRORS }
  end
  else
    result := value;
end;

// --  --
function fdset(s: tSocket; v: pbool; fds: pfdset): pfdset; {$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
begin
  if (v <> nil) then begin
    //
    fds.fd_array[0] := s;
    fds.fd_count := 1;
    //
    result := fds;
  end
  else
    result := nil;
end;

// --  --
function select(s: tSocket; r, w, e: pbool; timeout: unsigned): int;
var
  fds_r: tfdset;
  fds_w: tfdset;
  fds_e: tfdset;
  //
  fds_rptr: pfdset;
  fds_wptr: pfdset;
  fds_eptr: pfdset;
  //
  tv: tTimeval;
  timeptr: pTimeval;
begin
  if (INVALID_SOCKET <> s) then begin
    //
    fds_rptr := fdset(s, r, @fds_r);
    fds_wptr := fdset(s, w, @fds_w);
    fds_eptr := fdset(s, e, @fds_e);
    //
    if (timeout <> INFINITE) then begin
      //
      if (1 > timeout) then begin
	//
	tv.tv_sec  := 0;
	tv.tv_usec := 0;
      end
      else begin
	//
	tv.tv_sec := timeout shr 10;					// ~ timeout div 1000
	if (1 = timeout) then
	  tv.tv_usec := 1
	else
	  tv.tv_usec := ((timeout - unsigned(tv.tv_sec) shl 10) shl 10);	// ~ (timeout mod 1000) * 1000;
	//
	if (999999 < tv.tv_usec) then
	  tv.tv_usec := 999999;
      end;
      //
      timeptr := @tv;
    end
    else
      timeptr := nil;
    //
    result := WinSock.select(1, fds_rptr, fds_wptr, fds_eptr, timeptr);
    if (1 = result) then begin
      //
      if (r <> nil) then r^ := FD_ISSET(s, fds_r);
      if (w <> nil) then w^ := FD_ISSET(s, fds_w);
      if (e <> nil) then e^ := FD_ISSET(s, fds_e);
    end
    else begin
      //
      if (0 = result) then // timeout?
      else
	result := checkError(result, true);
    end;
    //
  end
  else
    result := WSAENOTSOCK;
end;

// --  --
function lookupHost(const host: string): int;
var
  ip: string;
begin
  result := lookupHost(host, ip);
end;

// --  --
function lookupHost(const host: string; defValue: unsigned): unsigned;
var
  ip: string;
begin
  if (0 = lookupHost(host, ip)) then
    result := str2ipH(ip)
  else
    result := defValue;
end;

// --  --
function lookupHost(const host: string; out ip: string; list: unaStringList): int;
var
  addr: unsigned;
  phost: pHostEnt;
  ok: bool;
  ar: pUInt32;
  added: bool;
begin
  ip := '';
  //
  if (length(trimS(host)) >= 0) then begin
    //
    result := 0;
    //
    if (nil <> g_unaWSA) then
      ok := g_unaWSA.f_gate.enter(5000{$IFDEF DEBUG}, g_unaWSA._classID{$ENDIF})
    else
      ok := true;
    //
    if (ok) then begin
      try
	//
	added := false;
	addr := unsigned(inet_addr(paChar(aString(host))));
	if ((addr = DWORD(INADDR_NONE)) or (addr = INADDR_ANY)) then begin
	  //
	  // try to resolve the name
	  phost := gethostbyname(paChar(aString(host)));
	  //
	  if (phost = nil) then
	    result := WSAGetLastError()
	  else begin
	    //
	    move(phost.h_addr^[0], addr, 4);
	    if (nil <> list) then begin
	      //
	      ar := pointer(phost.h_addr_list);
	      while (0 <> ar^) do begin
		//
		list.add(string(inet_ntoa(in_addr(ar^))));
		//
		inc(ar);
	      end;
	      //
	      added := true;
	    end;
	  end;
	end;
	//
	if (0 = result) then begin
	  // return IP address
	  ip := string(inet_ntoa(in_addr(addr)));
	  //
	  if ((nil <> list) and not added) then
	    list.add(ip);
	end;
	//
      finally
	//
	if (nil <> g_unaWSA) then
	  g_unaWSA.f_gate.Leave();
      end;
      //
    end;
  end
  else
    result := -1;
end;

// -- --
function getHostInfo(ip: uint32): string;
var
  he: pHOSTENT;
begin
  ip := uint32(htonl(int(ip)));
  he := gethostbyaddr(@ip, sizeOf(ip), AF_INET);
  //
  if (nil = he) then
    result := ipN2str(ip)
  else
    result := string(he.h_name);
end;

// -- --
function listAddresses(const host: string; list: unaStringList): int; overload;
var
  ip: string;
begin
  list.clear();
  result := lookupHost(host, ip, list);
end;

// -- --
function lookupPort(const port: string): int;
var
  port_info: protoent;
begin
  result := lookupPort(port, port_info);
  if (0 = result) then
    result := port_info.p_proto;
end;

// -- --
function lookupPort(const port: string; out port_info: protoent): int;
var
  iport: int;
  pport: pProtoEnt;
begin
  if (0 < length(port)) then begin
    //
    result := 0;
    iport  := str2intInt(port, -1);
    //
    if ((iport < 0) or (iport > $ffff)) then
      // try to resolve as name
      pport := getprotobyname(paChar(aString(port)))
    else
      // try to convert an int
      pport := getprotobynumber(iport);
    //
    if (pport = nil) then begin
      //
      result := WSAGetLastError();
      if (result = WSANO_DATA) and (iport >= 0) and (iport <= $ffff) then begin
	//
	port_info.p_name  := nil;
	port_info.p_aliases := nil;
	port_info.p_proto := smallint(iport);
	result := 0;
      end;
    end
    else
      port_info := pport^;
    //
  end
  else
    result := -1;
end;

// --  --
function ipH2str(ip: unsigned): string;
var
  inAddr: in_addr;
begin
  inAddr.s_addr := htonl(int(ip));
  result := string(inet_ntoa(inAddr));
end;

// --  --
function ipN2str(ip: unsigned): string;
var
  inAddr: in_addr;
begin
  unsigned(inAddr.s_addr) := ip;
  result := string(inet_ntoa(inAddr));
end;

// --  --
function str2ipH(const ip: string): unsigned;
begin
  result := unsigned(ntohl(inet_addr(paChar(aString(ip)))));
end;

// --  --
function str2ipN(const ip: string): unsigned;
begin
  result := unsigned(inet_addr(paChar(aString(ip))));
end;

// --  --
function addr2str(addr: pSockAddrIn): string;
begin
  if (nil <> addr) then
    result := string(inet_ntoa(addr.sin_addr)) + ':' + int2str(ntohs(addr.sin_port))
  else
    result := '<nil>';
end;

// --  --
function isMulticastAddr(const addr: string): bool;
begin
  result := isMulticastAddrN(str2ipN(addr));
end;

// --  --
function isMulticastAddrH(ip: DWORD): bool;
begin
  ip := (ip shr 24) and $FF;
  result := ((224 <= ip) and (ip <= 239));
end;

// --  --
function isMulticastAddrN(ip: DWORD): bool;
begin
  ip := ip and $FF;
  result := ((224 <= ip) and (ip <= 239));
end;

// --  --
function isBroadcastAddrN(ip: DWORD): bool;
begin
  result := ($FF = (ip shr 24 and $FF));	// lame, but should work in most cases
end;

// --  --
function sameAddr(const addr1, addr2: sockaddr_in): bool;
begin
  result := (
  	      ((0 = addr1.sin_port) or (0 = addr2.sin_port) or (addr1.sin_port = addr2.sin_port)) and
	      (addr1.sin_addr.S_addr = addr2.sin_addr.s_addr)
	    );
end;

// --  --
function makeAddr(const host, port: string; var addr: sockaddr_in): bool;
begin
  fillChar(addr, sizeof(sockaddr_in), #0);
  addr.sin_family := AF_INET;
  addr.sin_port := htons(u_short( lookupPort(port) ));
  addr.sin_addr.s_addr := inet_addr(paChar( aString( ipH2str(lookupHost(host, 0)) )));
  //
  result := (0 <> addr.sin_port) and (0 <> addr.sin_addr.s_addr);
end;


{ unaWSA }

// --  --
constructor unaWSA.create(active: bool; version: unsigned);
begin
  inherited create();
  //
  f_status := WSASYSNOTREADY;
  //
  f_gate := unaInProcessGate.create({$IFDEF DEBUG}_classID + '(f_gate)'{$ENDIF});
  //
  if (active) then
    startup(version);
end;

// --  --
destructor unaWSA.destroy();
begin
  if (isActive()) then
    shutdown();
  //
  freeAndNil(f_gate);
  //
  inherited;
end;

// --  --
function unaWSA.getStatus(): int;
begin
  result := f_status;
end;

// --  --
function unaWSA.isActive(): bool;
begin
  result := (f_status = 0);
end;

// --  --
function unaWSA.shutdown(): int;
begin
  result := WSACleanup();
end;

// --  --
function unaWSA.startup(version: unsigned): int;
begin
  f_status := WSAStartup(version, f_data);
  //
  result := f_status;
end;

{ unaSocket }

// --  --
function unaSocket.accept(out socket: tSocket; timeout: unsigned): unaSocket;
var
  addr: sockaddr_in;
  len : int;
begin
  result := nil;
  len := sizeof(addr);
  //
  if (check_read(timeout)) then begin
    //
    socket := winSock.accept(f_socket, @addr, @len);
    if (socket <> INVALID_SOCKET) then begin
      //
      result := unaSocket.create({$IFDEF VC25_OVERLAPPED }f_overlapped{$ENDIF });
      result.f_socket := socket;
      result.f_addressFamily := addr.sin_family;
      result.f_socketProtocol := socketProtocol;
      result.f_socketType := socketType;
      //
      lookupHost(string(inet_ntoa(addr.sin_addr)), result.f_host);
      lookupPort(int2str(ntohs(addr.sin_port)), result.f_port);
    end
    else
      socket := checkError(SOCKET_ERROR, true {$IFDEF DEBUG}, self._classID + '.accept()'{$ENDIF});
    //  
  end
  else
    socket := WSAETIMEDOUT;
end;

// --  --
function unaSocket.bind(addr: pSockAddrIn): int;
var
  laddr: sockaddr_in;
begin
  result := socket();
  if (0 = result) then begin
    //
    if (addr <> nil) then
      laddr := addr^
    else begin
      //
      laddr.sin_family := AF_INET;
      if (0 = word(f_bindToPort.p_proto)) then
	laddr.sin_port := htons(u_short(getPortInt()))
      else
	laddr.sin_port := htons(u_short(f_bindToPort.p_proto));
      //
      laddr.sin_addr.s_addr := inet_addr(paChar(aString(f_bindToIp)));
      if (DWORD(INADDR_NONE) = unsigned(laddr.sin_addr.s_addr)) then
	unsigned(laddr.sin_addr.s_addr) := INADDR_ANY;
      //
    end;
    //
    result := checkError(WinSock.bind(f_socket, laddr, sizeof(laddr)), true {$IFDEF DEBUG}, self._classID + '.bind()'{$ENDIF});
  end;
end;

// --  --
function unaSocket.bindSocketToPort(port: int): int;
var
  laddr: sockaddr_in;
begin
  laddr.sin_family := AF_INET;
  if (0 > port) then begin
    //
    if (0 = word(f_bindToPort.p_proto)) then
      laddr.sin_port := 0	// use first availabe port
    else
      laddr.sin_port := htons(u_short(f_bindToPort.p_proto));
  end
  else
    laddr.sin_port := htons(u_short(port));
  //
  laddr.sin_addr.s_addr := inet_addr(paChar(aString(f_bindToIp)));
  if (DWORD(INADDR_NONE) = unsigned(laddr.sin_addr.s_addr)) then
    unsigned(laddr.sin_addr.s_addr) := INADDR_ANY;
  //
  result := bind(@laddr);
end;

// --  --
function unaSocket.check_error(timeout: unsigned): bool;
var
  e: bool;
  r: int;
begin
  if (INVALID_SOCKET = f_socket) then begin
    //
    result := true
  end
  else begin
    //
    r := select(f_socket, nil, nil, @e, timeout);
    //
    if (r = 1) then
      result := e
    else
      result := (r <> 0);
  end;
end;

// --  --
function unaSocket.check_read(timeout: unsigned): bool;
var
  r: bool;
begin
  if (1 = select(f_socket, @r, nil, nil, timeout)) then
    result := r
  else
    result := false;
end;

// --  --
function unaSocket.check_write(timeout: unsigned): bool;
var
  w: bool;
begin
  if (1 = select(f_socket, nil, @w, nil, timeout)) then
    result := w
  else
    result := false;
end;

// --  --
function unaSocket.close(graceful: bool): int;
begin
  if ((INVALID_SOCKET <> f_socket) and not isListening() and graceful) then
    result := shutdown(SD_BOTH)
  else
    result := 0;
  //
  if ((WSAENOTCONN = result) or (0 = result)) then
    result := closeSocket();
  //
  f_MTUValid := false;
end;

// --  --
function unaSocket.closeSocket(): int;
begin
  if (INVALID_SOCKET <> f_socket) then begin
    //
    result := checkError(WinSock.closeSocket(f_socket), true {$IFDEF DEBUG}, self._classID + '.closeSocket()'{$ENDIF});
    if (0 = result) then
      f_socket := INVALID_SOCKET;
    //
  end
  else
    result := 0;
  //
  f_MTUValid := false;
end;

// --  --
function unaSocket.connect(addr: pSockAddrIn): int;
var
  laddr: sockaddr_in;
begin
  if ((IPPROTO_TCP = socketProtocol) and isActive) then begin
    //
    result := 0;
  end
  else begin
    //
    result := socket();
    if (0 = result) then begin
      //
      if (nil = addr) then begin
	//
	result := getSockAddr(laddr)
      end
      else begin
	//
	f_port.p_proto := ntohs(addr.sin_port);
	f_host := string(inet_ntoa(addr.sin_addr));
	//
	laddr := addr^;
	result := 0;
      end;
      //
      if (0 = result) then begin
	//
	bindSocketToPort();	// bind the socket to first available (or specified with bindToPort) port before connecting
	//
	// even if explicit bind fail, connect will bind the socket to first availbale port number
	{$IFDEF VC25_OVERLAPPED }
	//
	if (f_overlapped) then begin
	  //
	  result := WSAConnect(f_socket, @laddr, sizeof(laddr), nil, nil, nil, nil);
	  if ((SOCKET_ERROR = result) and (WSAEWOULDBLOCK = WSAGetLastError())) then
	    result := 0
	  else
	    result := checkError(WSAGetLastError());
	end
	else
	  result := checkError(WinSock.connect(f_socket, laddr, sizeof(laddr)), true {$IFDEF DEBUG}, self._classID + '.connect()'{$ENDIF});
	//
	{$ELSE }
	//
	result := checkError(WinSock.connect(f_socket, laddr, sizeof(laddr)), true {$IFDEF DEBUG}, self._classID + '.connect()'{$ENDIF});
	{$ENDIF VC25_OVERLAPPED }
      end;
      //
    end;
  end;
end;

// --  --
constructor unaSocket.create({$IFDEF VC25_OVERLAPPED }overlapped: bool{$ENDIF VC25_OVERLAPPED });
begin
  inherited create();
  //
  f_socket := INVALID_SOCKET;
  {$IFDEF VC25_OVERLAPPED }
  f_overlapped := overlapped;
  {$ENDIF VC25_OVERLAPPED }
  //
  f_bindToIP := '0.0.0.0';
end;

// --  --
constructor unaSocket.create(socket: tSocket; addressFamily, socketProtocol, socketType: int; const addr: sockaddr_in; len: int);
begin
  inherited create();
  //
  f_socket := socket;
  f_addressFamily := addressFamily;
  f_socketProtocol := socketProtocol;
  f_socketType := socketType;
  //
  f_bindToIP := '0.0.0.0';
  //
  lookupHost(string(inet_ntoa(addr.sin_addr)), f_host);
  lookupPort(int2str(ntohs(addr.sin_port)), f_port);
end;

// --  --
destructor unaSocket.destroy();
begin
  close();
  //
  inherited;
end;

// --  --
function unaSocket.getBindToPort(): string;
begin
  result := int2str(f_bindToPort.p_proto);
end;

// --  --
function unaSocket.getBufSize(index: Integer): unsigned;
begin
  case (index) of

    0: result := getOptInt(SO_SNDBUF);
    1: result := getOptInt(SO_RCVBUF);

    else
      result := 0;
  end;
end;

// --  --
class function unaSocket.getGeneralMTU(): unsigned;
begin
{
Below is a list of Default MTU size for different media.

   Network                  MTU(Bytes)
   -----------------------------------
   16 Mbit/Sec Token Ring    17914
   4 Mbits/Sec Token Ring     4464
   FDDI                       4352
   Ethernet                   1500
   IEEE 802.3/802.2           1492
   X.25                        576
}
  if (nil <> g_unaWSA) then begin
    //
    result := word(g_unaWSA.f_data.iMaxUdpDg);
    if (0 = result) then
      result := 1500;
    //
  end
  else
    result := 0;
end;

// --  --
function unaSocket.getIsActive(): bool;
begin
  result := (isConnected() or isListening());
end;

// --  --
function unaSocket.getMTU(): unsigned;
begin
  if (not f_MTUValid) then begin
    //
    f_MTU := word(uint32(getOptInt(SO_MAX_MSG_SIZE)));
    f_MTUValid := true;
  end;
  //
  result := f_MTU
end;

// --  --
function unaSocket.getOptBool(opt: int): bool;
var
  c: Windows.BOOL;
  len: int;
begin
  if (not check_error()) then begin
    //
    len := sizeOf(c);
    if (0 = checkError(getsockopt(f_socket, SOL_SOCKET, opt, paChar(@c), len), true {$IFDEF DEBUG}, self._classID + '.getOptBool()'{$ENDIF})) then
      result := ((len > 0) and c)
    else
      result := false;
  end
  else
    result := false;
end;

// --  --
function unaSocket.getOptInt(opt: int): int;
var
  len: int;
begin
  if (INVALID_SOCKET <> f_socket) then begin
    //
    len := sizeof(result);
    checkError(getsockopt(f_socket, SOL_SOCKET, opt, paChar(@result), len), true {$IFDEF DEBUG}, self._classID + '.getOptInt()'{$ENDIF});
    if (len < sizeof(result)) then
      result := -2;
  end
  else
    result := -1;
end;

// --  --
function unaSocket.getPendingDataSize(noCheckState: bool): unsigned;
var
  len: int;
begin
  if (noCheckState or okToRead()) then
    //
    if (0 <> ioctl(FIONREAD, len)) then
      result := 0
    else
      result := len
  else
    result := 0;
end;

// --  --
function unaSocket.getPort(): string;
begin
  if (f_port.p_name = nil) then
    result := int2str(f_port.p_proto)
  else
    result := string(f_port.p_name);
end;

// --  --
function unaSocket.getPortInt(): word;
begin
  result := word(f_port.p_proto);
end;

// --  --
function unaSocket.getSockAddr(out addr: sockaddr_in): int;
var
  ip: string;
begin
  fillChar(addr, sizeof(sockaddr_in), #0);
  //
  addr.sin_family := addressFamily;
  if ('' = host) then begin
    //
    addr.sin_addr.s_addr := inet_addr(paChar(aString(f_bindToIp)));
    if (DWORD(INADDR_NONE) = unsigned(addr.sin_addr.s_addr)) then
      unsigned(addr.sin_addr.s_addr) := INADDR_ANY;
    //
    result := 0;
  end
  else begin
    //
    result := lookupHost(host, ip);
    if (0 = result) then
      addr.sin_addr.s_addr := inet_addr(paChar(aString(ip)));
    //
  end;
  //
  if (0 = result) then
    addr.sin_port := htons(u_short(getPortInt()));
end;

// --  --
function unaSocket.getSockAddrBound(out addr: sockaddr_in): int;
var
  sz: int;
begin
  sz := sizeOf(addr);
  result := checkError(getsockname(f_socket, addr, sz));
end;

// --  --
function unaSocket.getSocket(forceCreate: bool): tSocket;
begin
  if ((INVALID_SOCKET = f_socket) or forceCreate) then
    socket();
  //
  result := f_socket;
end;

// --  --
function unaSocket.ioctl(command: unsigned; var param: int): int;
begin
  result := checkError(WinSock.ioctlsocket(f_socket, command, param), true {$IFDEF DEBUG}, self._classID + '.ioctl()'{$ENDIF});
end;

// --  --
function unaSocket.isConnected(timeout: unsigned): bool;
begin
  result := not check_error(timeout) and okToWrite(timeout);
end;

// --  --
function unaSocket.isListening(): bool;
begin
  if (SOCK_DGRAM = socketType) then
    result := false	// UDP sockets simply binds to local port
  else
    result := getOptBool(SO_ACCEPTCONN);
end;

// --  --
function unaSocket.listen(backlog: int): int;
begin
  if (isListening()) then
    result := 0
  else begin
    //
    result := bind(nil);
    //
    if (0 = result) then
      result := checkError(WinSock.listen(f_socket, backlog), true {$IFDEF DEBUG}, self._classID + '.listen()'{$ENDIF});
  end;
end;

// --  --
function unaSocket.oktoRead(timeout: unsigned; noCheckState: bool): bool;
begin
  result := (noCheckState or check_read(timeout));
end;

// --  --
function unaSocket.oktoWrite(timeout: unsigned; noCheckState: bool): bool;
begin
  result := (noCheckState or check_write(timeout));
end;

// --  --
function unaSocket.read(const buf: pointer; var size: unsigned; timeout: unsigned; noCheck: bool): int;
var
  e: int;
begin
  if (noCheck or (isActive and waitForData(timeout, true))) then begin
    //
    e := recv(f_socket, buf^, size, 0);
    if (SOCKET_ERROR = e) then
      result := checkError(e, true {$IFDEF DEBUG}, self._classID + '.read()'{$ENDIF})
    else begin
      //
      size := e;
      result := 0;
    end;
  end
  else
    result := -1;
  //
  if (WSAECONNRESET = result) then
    close();
end;

// --  --
function unaSocket.readString(noCheck: bool): aString;
var
  len: unsigned;
begin
  result := '';
  len := getPendingDataSize();
  //
  if (len > 0) then begin
    //
    SetLength(result, len);
    if (read(@result[1], len, 100, noCheck) = 0) then
      SetLength(result, len)
    else
      result := '';
    //
  end;
end;

// --  --
function unaSocket.send(buf: pointer; size: unsigned; noCheck: bool): int;
begin
  if (noCheck or okToWrite(1)) then begin
    //
    result := WinSock.send(f_socket, buf^, size, 0);
    if (SOCKET_ERROR = result) then begin
      //
      result := checkError(result, true {$IFDEF DEBUG}, self._classID + '.send()'{$ENDIF})
    end
    else begin
      //
      if (unsigned(result) = size) then
	result := 0
      else
	result := -2;
      //
    end;
  end
  else begin
    //
    result := -1;
    {$IFDEF LOG_UNASOCKETS_ERRORS }
    logMessage(self._classID + '.send() - okToWrite() fails.');
    {$ENDIF LOG_UNASOCKETS_ERRORS }
  end;
end;

// --  --
function unaSocket.send(const value: aString; noCheck: bool): int;
begin
  result := send(@value[1], Length(value), noCheck);
end;

// --  --
procedure unaSocket.setBindToPort(const value: string);
begin
  lookupPort(value, f_bindToPort);
end;

// --  --
procedure unaSocket.setBufSize(index: int; value: unsigned);
begin
  case (index) of

    0: setOptInt(SO_SNDBUF, value);
    1: setOptInt(SO_RCVBUF, value);

  end;
end;

// --  --
procedure unaSocket.setHost(const host: string);
begin
  if (not isActive) then
    f_host := trimS(host);
end;

// --  --
function unaSocket.setOptBool(opt: int; value: bool): int;
var
  len: int;
  val: Windows.BOOL;
begin
  if (INVALID_SOCKET <> f_socket) then begin
    //
    val := value;
    len := sizeof(val);
    result := checkError(setsockopt(f_socket, SOL_SOCKET, opt, paChar(@val), len), true {$IFDEF DEBUG}, self._classID + '.setOptBool()'{$ENDIF});
  end
  else
    result := -1;
end;

// --  --
function unaSocket.setOptInt(opt, value: int): int;
var
  len: int;
begin
  if (INVALID_SOCKET <> f_socket) then begin
    //
    len := sizeof(value);
    result := checkError(setsockopt(f_socket, SOL_SOCKET, opt, paChar(@value), len), true {$IFDEF DEBUG}, self._classID + '.setOptInt()'{$ENDIF});
  end
  else
    result := -1;
end;

// --  --
function unaSocket.setPort(port: word; noCheck: bool): bool;
begin
  result := setPort(int2str(port), noCheck);
end;

// --  --
function unaSocket.setPort(const port: string; noCheck: bool): bool;
begin
  if (not noCheck and isActive) then
    result := false
  else
    result := (lookupPort(port, f_port) = 0);
end;

// --  --
function unaSocket.shutdown(how: int): int;
begin
  if (isActive) then
    result := checkError(WinSock.shutdown(f_socket, how), true {$IFDEF DEBUG}, self._classID + '.shutdown()'{$ENDIF})
  else
    result := 0;
  //
  f_MTUValid := false;
end;

// --  --
function unaSocket.socket(): int;
begin
  if (INVALID_SOCKET = f_socket) then begin
    //
    {$IFDEF VC25_OVERLAPPED }
    if (f_overlapped) then begin
      //
      f_socket := WSASocket(addressFamily, socketType, socketProtocol, nil, 0, WSA_FLAG_OVERLAPPED);
    end
    else
      f_socket := WinSock.socket(addressFamily, socketType, socketProtocol);
    {$ELSE }
    f_socket := WinSock.socket(addressFamily, socketType, socketProtocol);
    {$ENDIF VC25_OVERLAPPED }
  end;
  //
  if (INVALID_SOCKET = f_socket) then
    result := checkError(SOCKET_ERROR, true {$IFDEF DEBUG }, self._classID + '.socket()'{$ENDIF DEBUG })
  else
    result := 0;
end;

// --  --
function unaSocket.waitForData(timeout: unsigned; noCheckState: bool): bool;
begin
  result := okToRead(timeout, noCheckState) and (0 < getPendingDataSize(true));
end;


{ unaTcpSocket }

// --  --
constructor unaTcpSocket.create({$IFDEF VC25_OVERLAPPED }overlapped: bool{$ENDIF VC25_OVERLAPPED });
begin
  inherited;
  //
  f_addressfamily := AF_INET;
  f_socketProtocol := IPPROTO_TCP;
  f_socketType := SOCK_STREAM;
end;

// --  --
function unaTcpSocket.doBind(addr: pSockAddrIn): int;
begin
  result := bind(addr);
end;


{ unaUdpSocket }

// --  --
constructor unaUdpSocket.create({$IFDEF VC25_OVERLAPPED }overlapped: bool{$ENDIF VC25_OVERLAPPED });
begin
  inherited;
  //
  f_addressfamily := AF_INET;
  f_socketProtocol := IPPROTO_UDP;
  f_socketType := SOCK_DGRAM;
end;

// --  --
function unaUdpSocket.recvfrom(out from: sockaddr_in; var data: aString; noCheck: bool; flags: unsigned; timeout: unsigned): int;
var
  len: unsigned;
  sizeFrom: int;
begin
  if (noCheck or oktoRead(timeout)) then begin
    //
    data := '';
    len := getMTU();
    if (0 < len) then begin
      //
      setLength(data, len);
      sizeFrom := sizeof(from);
      //
      result := WinSock.recvfrom(f_socket, data[1], len, flags, from, sizeFrom);
      if (SOCKET_ERROR = result) then begin
	//
	result := checkError(result, true {$IFDEF DEBUG}, self._classID + '.recvfrom()'{$ENDIF});
	data := '';
      end
      else
	setLength(data, result);
      //
    end
    else
      result := -1;
  end
  else
    result := -2;
end;

// --  --
function unaUdpSocket.doBind(addr: pSockAddrIn): int;
begin
  result := bind(addr);
end;

// --  --
function unaUdpSocket.recvfrom(out from: sockaddr_in; data: pointer; dataLen: unsigned; noCheck: bool; flags: unsigned; timeout: unsigned): int;
var
  sizeFrom: int;
begin
  if (noCheck or oktoRead(timeout)) then begin
    //
    sizeFrom := sizeof(from);
    result := WinSock.recvfrom(f_socket, data^, int(dataLen), int(flags), from, sizeFrom);
  end
  else
    result := -2;
end;

// --  --
function unaUdpSocket.sendto(var addr: sockaddr_in; const data: aString; flags: unsigned; timeout: unsigned): unsigned;
begin
  if (0 < length(data)) then
    result := sendto(addr, @data[1], length(data), flags, timeout)
  else
    result := 0;
end;

// --  --
function unaUdpSocket.sendto(var addr: sockaddr_in; data: pointer; size, flags: unsigned; timeout: unsigned; noCheck: bool): unsigned;
var
  err: int;
  offset: unsigned;
  subsize: unsigned;
begin
  if (noCheck or oktoWrite(timeout)) then begin
    //
    result := 0;
    offset := 0;
    while (offset < size) do begin
      //
      subsize := min(getMTU(), size - offset);
      if (0 < subsize) then begin
	//
	err := WinSock.sendto(f_socket, pArray(data)[offset], subsize, flags, addr, sizeof(addr));
	if (SOCKET_ERROR <> err) then begin
	  //
	  inc(offset, err)
	end
	else begin
	  //
	  result := checkError(err, true {$IFDEF DEBUG}, self._classID + '.sendto()'{$ENDIF});
	  break;
	end;
      end;
    end;
    //
    if ((0 = result) and (offset < size)) then
      result := WSAETIMEDOUT;
  end
  else
    result := WSAEACCES;	// select() fails
  //
end;

// --  --
function unaUdpSocket.sendto(var addr: sockaddr_in; data: pointer; size: unsigned; noCheck: bool; flags: unsigned): unsigned;
begin
  result := sendto(addr, data, size, flags, 10, noCheck);
end;

// --  --
function unaUdpSocket.sendto(var addr: sockaddr_in; const data: aString; noCheck: bool; flags: unsigned): unsigned;
begin
  if (0 < length(data)) then
    result := sendto(addr, @data[1], length(data), flags, 0, noCheck)
  else
    result := 0;
end;

{ unaMulticastSocket }

// --  --
function unaMulticastSocket.closeSocket(): int;
begin
  f_isReadySender := false;
  f_isReadyReceiver := false;
  //
  result := inherited closeSocket();
end;

// --  --
function unaMulticastSocket.isReady(sender: bool): bool;
begin
  result := choice(sender, f_isReadySender, f_isReadyReceiver);
end;

// --  --
function unaMulticastSocket.recGroupDrop(const groupAddr: string): int;
var
  drop: string;
  mr: ip_mreq;
begin
  if (f_isReadyReceiver) then begin
    //
    if ('' = groupAddr) then
      drop := f_recLastGroup
    else
      drop := groupAddr;
    //
    if ('' <> drop) then begin
      //
      mr.imr_multiaddr.s_addr := inet_addr(paChar(aString(drop)));
      if (DWORD(INADDR_NONE) <> unsigned(mr.imr_multiaddr.s_addr)) then begin
	//
	mr.imr_interface.s_addr := inet_addr(paChar(aString(bindToIP)));
	if (DWORD(INADDR_NONE) = unsigned(mr.imr_interface.s_addr)) then
	  unsigned(mr.imr_interface.s_addr) := INADDR_ANY;
	//
	result := checkError(setsockopt(f_socket, IPPROTO_IP, IP_DROP_MEMBERSHIP, paChar(@mr), sizeOf(mr)));
	//
	if (0 = result) then begin
	  //
	  f_recLastGroup := '';
	  dec(f_recGroupCount);
	  //
	  f_isReadyReceiver := (0 < f_recGroupCount);
	  //
	  if (not f_isReadyReceiver) then
	    close();
	  //
	end;
      end
      else
	result := WSAEADDRNOTAVAIL;
      //
    end
    else
      result := WSAEADDRNOTAVAIL;
    //
  end
  else
    result := 0;	// no socket, no drop
end;

// --  --
function unaMulticastSocket.recGroupJoin(const groupAddr: string): int;
var
  mr: ip_mreq;
begin
  if (not f_isReadyReceiver) then
    result := checkError(bind())
  else
    result := 0;	// OK since we has already joined some group
  //
  if (0 = result) then begin
    //
    mr.imr_multiaddr.s_addr := inet_addr(paChar(aString(groupAddr)));
    if (DWORD(INADDR_NONE) <> unsigned(mr.imr_multiaddr.s_addr)) then begin
      //
      mr.imr_interface.s_addr := inet_addr(paChar(aString(bindToIP)));
      if (DWORD(INADDR_NONE) = unsigned(mr.imr_interface.s_addr)) then
	unsigned(mr.imr_interface.s_addr) := INADDR_ANY;
      //
      result := checkError(setsockopt(f_socket, IPPROTO_IP, IP_ADD_MEMBERSHIP, paChar(@mr), sizeOf(mr)));
      if (0 = result) then begin
	//
	f_recLastGroup := groupAddr;
	inc(f_recGroupCount);
	//
	f_isReadyReceiver := true;
      end;
    end
    else
      result := WSAEADDRNOTAVAIL;
  end;
  //
  if ((0 <> result) and not f_isReadyReceiver) then
    close();	// close the socket we had bound but not used
end;

// --  --
function unaMulticastSocket.senderCreate(ttl, enableLoop: DWORD; noBind: bool): int;
var
  ip: DWORD;
  lp: Windows.BOOL;
begin
  if (f_isReadySender) then
    close();
  //
  ip := DWORD(inet_addr(paChar(aString(host))));
  if ((0 < ip) and (DWORD(INADDR_NONE) <> ip)) then begin
    //
    if (isMulticastAddrN(ip)) then begin
      //
      if (noBind) then
	result := socket()
      else
	result := checkError(bind());	// bind a socket to port/interface
      //
      if (0 = result) then begin
	//
	ip := DWORD(inet_addr(paChar(aString(f_bindToIp))));
	if (DWORD(INADDR_NONE) = ip) then
	  ip := INADDR_ANY;
	//
	if (INADDR_ANY <> ip) then begin
	  //
	  // set the multicast interface
	  // even if this call fails, that in not a fatal error
	  checkError(setsockopt(f_socket, IPPROTO_IP, IP_MULTICAST_IF, paChar(@ip), sizeOf(ip)), false);
	end;
	//
	// set the multicast TTL
	result := checkError(setsockopt(f_socket, IPPROTO_IP, IP_MULTICAST_TTL, paChar(@ttl), sizeOf(dword)));
	//
	if ((0 = result) and (0 = enableLoop)) then begin
	  //
	  // try disbaling a loop (which is ON by default)
	  lp := false;
	  result := checkError(setsockopt(f_socket, IPPROTO_IP, IP_MULTICAST_LOOP, paChar(@lp), sizeOf(lp)), false);
	  //
	  f_loopDisableForce := (0 <> result);
	  //
	  result := 0;	// loop option is not a fatal error
	end;
	//
	if (0 = result) then begin
	  //
	  // prepare an address for sending
	  fillChar(f_senderAddr, sizeOf(f_senderAddr), #0);
	  f_senderAddr.sin_family := AF_INET;
	  f_senderAddr.sin_addr.s_addr := inet_addr(paChar(aString(host)));
	  f_senderAddr.sin_port := htons(u_short(getPortInt()));
	  //
	  f_isReadySender := (0 = result);
	end;
      end;
    end
    else
      result := WSAEADDRNOTAVAIL;
    //
  end
  else
    result := WSAEADDRNOTAVAIL;
  //
  if (0 <> result) then
    close();
end;

// --  --
function unaMulticastSocket.senderSend(data: pointer; len: int; noCheck: bool): int;
begin
  if (f_isReadySender) then
    result := sendto(f_senderAddr, data, len, 0, 1, noCheck)
  else
    result := WSAENOTSOCK;
end;

// --  --
function unaMulticastSocket.senderSend(const data: aString; noCheck: bool): int;
begin
  if ('' <> data) then
    result := senderSend(@data[1], length(data), noCheck)
  else
    result := 0;
end;



{ unaSocksConnection }

// --  --
function unaSocksConnection.acquire(timeout: unsigned): bool;
begin
  result := f_gate.enter(timeout);
  if (result and f_destroying) then begin
    //
    release();
    result := false
  end;
end;

// --  --
procedure unaSocksConnection.beforeDestruction();
begin
  if (acquire(2000)) then begin
    try
      // make sure no one will acquire us any more
      f_destroying := true;
    finally
      f_gate.leave();
    end;
  end;
  //
  Sleep(100);	// give other threads a chance to understand we are about to be desroyed..
  //
  f_thread.onConnectionRemove(f_connId);
  //
  if (f_thread.threadSocket <> f_threadSocket) then
    freeAndNil(f_threadSocket);
  //
  inherited;
  //
  freeAndNil(f_gate);
end;

// --  --
function unaSocksConnection.compareAddr(const addr: sockaddr_in): bool;
begin
  result := ((addr.sin_port = f_addr.sin_port) and (addr.sin_addr.S_addr = f_addr.sin_addr.s_addr));
end;

// --  --
constructor unaSocksConnection.create(thread: unaSocksThread; connId: unsigned; socket: unaSocket; addr: pSockAddrIn; len: int);
begin
  inherited create();
  //
  f_thread := thread;
  f_connId := connId;
  f_threadSocket := socket;
  //
  f_gate := unaInProcessGate.create();
  //
  if (nil <> addr) then
    f_addr := addr^
  else
    socket.getSockAddr(f_addr);
  //
  f_destroying := false;
  //
  resetTimeout();
end;

// --  --
function unaSocksConnection.getAddr(): pSockAddrIn;
begin
  result := @f_addr;
end;

// --  --
function unaSocksConnection.getTimeout(): unsigned;
begin
  result := timeElapsed32(f_lpStamp);
end;

// --  --
function unaSocksConnection.okToWrite(timeout: unsigned; noCheckState: bool): bool;
begin
  result := f_threadSocket.okToWrite(timeout, noCheckState);
end;

// --  --
procedure unaSocksConnection.release();
begin
  f_gate.leave();
end;

// --  --
procedure unaSocksConnection.resetTimeout();
begin
  f_lpStamp := timeMark();
end;

// --  --
function unaSocksConnection.send(data: pointer; size: unsigned; noCheck: bool): unsigned;
var
  res: int;
begin
  if ((IPPROTO_UDP = f_threadSocket.socketProtocol) and f_thread.f_isServer) then begin
    // UDP SERVER
    {
	WSAEISCONN (10056)
	Socket is already connected.
	A connect request was made on an already-connected socket.
	Some implementations also return this error if sendto is called on
	a connected SOCK_DGRAM socket, although other implementations treat
	this as a legal occurrence.
	//
	That is why we should not send data for connected UDP client sockets using sendto
    }
    {$IFDEF LOG_RAW_DATA_PACKETS }
    logMessage('UNA_SOCKETS: UDP SERVER / about to send new data packet, size=' + int2str(size) + '; CRC32=' + int2str(crc32(data, size), 16));
    {$ENDIF }
    //
    result := unaUdpSocket(f_threadSocket).sendto(f_addr, data, size, true);
  end
  else begin
    //
    {$IFDEF LOG_RAW_DATA_PACKETS }
    logMessage('UNA_SOCKETS: ' + choice(IPPROTO_UDP = f_threadSocket.socketProtocol, 'UDP', 'TCP') + ' ' + choice(f_thread.f_isServer, 'SERVER', 'CLIENT') + ' / about to send new data packet, size=' + int2str(size) + '; CRC32=' + int2str(crc32(data, size), 16));
    {$ENDIF }
    //
    res := f_threadSocket.send(data, size, noCheck or (SOCK_DGRAM = f_threadSocket.socketType));
    if (0 = res) then
      result := 0
    else begin
      //
      if (-1 = res) then
	result := WSAENOBUFS	// most likely...
      else
	result := WSAGetLastError();
      //
    end;  
  end;
end;


{ unaSocketsConnections }

// --  --
function unaSocketsConnections.get_connection(connId: unsigned; timeout: unsigned): unaSocksConnection;
begin
  result := itemById(connId, 0, timeout);
end;

// --  --
function unaSocketsConnections.getId(item: pointer): int64;
begin
  result := unaSocksConnection(item).connId;
end;


// -- packet storm helpers --

type
  //
  // -- unaPacketStormBuffer --
  //
  /// Internal packet buffer
  punaPacketStormBuffer = ^unaPacketStormBuffer;
  unaPacketStormBuffer = packed record
    //
    r_flags: unsigned;		// 0 - free
				// 1 - has data
				// 2 - pending (not free, and no data yet)
				//
    r_connId: unsigned;		// connection ID
    r_seqNum: int64;		// sequence num
    r_dataSize: unsigned;	// memory size allocated for buffer
    r_dataSizeUsed: unsigned;	// how much data is actually used
    r_data: pointer;		// data buffer
  end;


const
  // --  --
  c_maxPSBufs	= 4096;	/// max number of packet storm records.

type
  //
  // -- unaSocksPacketStormThread --
  //
  {*
  }
  unaSocksPacketStormThread = class(unaThread)
  private
    f_masterThread: unaSocksThread;
    f_masterEventType: unaSocketEvent;
    //
    f_bufLock: unaInProcessGate;
    f_buffers: array[0..c_maxPSBufs - 1] of unaPacketStormBuffer;
    f_bufCount: unsigned;
    //
    f_seqNum: int64;
    //
    //f_packetBuf: pointer;
    //f_packetBufSize: unsigned;
    //
    //f_streams: unaPacketStormStreams;
    //f_dataEvent: unaEvent;
  protected
    function execute(globalIndex: unsigned): int; override;
  public
    constructor create(masterThread: unaSocksThread);
    //
    procedure AfterConstruction(); override;
    procedure BeforeDestruction(); override;
    //
    procedure removeConnection(connId: unsigned);
    procedure bufferRelease(buf: punaPacketStormBuffer);
    function bufferGet(desiredSize: unsigned): punaPacketStormBuffer;
    //
    function newPacket(connId: unsigned; buf: punaPacketStormBuffer): bool;
  end;


{ unaSocksPacketStormThread }

// --  --
procedure unaSocksPacketStormThread.afterConstruction();
begin
  //f_streams := unaPacketStormStreams.create(true {$IFDEF DEBUG}, _classID + '(f_streams)'{$ENDIF});
  //
  //f_dataEvent := unaEvent.create();
  //f_removeStreamLock1 := unaInProcessGate.create();
  //f_removeStreamLock2 := unaInProcessGate.create();
  //
  //f_packetBuf := nil;
  //f_packetBufSize := 0;
  //
  f_bufLock := unaInProcessGate.create();
  f_bufCount := 0;
  //
  inherited;
end;

// --  --
procedure unaSocksPacketStormThread.beforeDestruction();
var
  i: unsigned;
begin
{$IFDEF LOG_SOCKS_THREADS }
  logMessage(_classID + '.beforeDestruction() - about to destroy..');
{$ENDIF }
  inherited;
  //
  //freeAndNil(f_streams);
  //freeAndNil(f_dataEvent);
  //
  //freeAndNil(f_removeStreamLock1);
  //freeAndNil(f_removeStreamLock2);
  //
  if ((0 < f_bufCount) and f_bufLock.enter()) then begin
    //
    try
      for i := 0 to f_bufCount - 1 do begin
	//
	if (0 < f_buffers[i].r_dataSize) then begin
	  //
	  f_buffers[i].r_dataSize := 0;
	  mrealloc(f_buffers[i].r_data);
	end;
      end;
    finally
      f_bufLock.leave();
    end;
  end;
  //
  freeAndNil(f_bufLock);
  //
{$IFDEF LOG_SOCKS_THREADS }
  logMessage(_classID + '.beforeDestruction() - done.');
{$ENDIF }
end;

// --  --
function unaSocksPacketStormThread.bufferGet(desiredSize: unsigned): punaPacketStormBuffer;
var
  i: unsigned;
  index: int;
begin
  result := nil;
  //
  if ((0 < desiredSize) and f_bufLock.enter(100)) then try
    //
    index := -1;
    //
    // find best match along free buffers
    if (0 < f_bufCount) then begin
      //
      for i := 0 to f_bufCount - 1 do begin
	//
	if ((0 = f_buffers[i].r_flags) and (f_buffers[i].r_dataSize >= desiredSize)) then begin
	  //
	  index := i;
	end;
      end;
    end;
    //
    // have we found anything at all? If no, can we add something?
    if ((0 > index) and (f_bufCount < c_maxPSBufs)) then begin
      //
      f_buffers[f_bufCount].r_connId := 0;
      f_buffers[f_bufCount].r_data := malloc(desiredSize);
      f_buffers[f_bufCount].r_dataSize := desiredSize;
      //
      index := f_bufCount;
      inc(f_bufCount);
    end;
    //
    if (0 <= index) then begin
      //
      result := @f_buffers[index];
      result.r_flags := 2;	// pending
      result.r_dataSizeUsed := 0;
      inc(f_seqNum);
      result.r_seqNum := f_seqNum;
    end;
    //
  finally
    f_bufLock.leave();
  end;
end;

// --  --
procedure unaSocksPacketStormThread.bufferRelease(buf: punaPacketStormBuffer);
begin
  if (f_bufLock.enter(100)) then try
    //
    buf.r_flags := 0;	// mark it as free
  finally
    f_bufLock.leave();
  end;
end;

// --  --
constructor unaSocksPacketStormThread.create(masterThread: unaSocksThread);
begin
  f_masterThread := masterThread;
  //
  f_seqNum := 1726;	// just a number to start with
  //
  if (f_masterThread.isServer) then
    f_masterEventType := unaseServerData
  else
    f_masterEventType := unaseClientData;
  //
  inherited create(false, THREAD_PRIORITY_TIME_CRITICAL);
end;

// --  --
function unaSocksPacketStormThread.execute(globalIndex: unsigned): int;
var
  i, cnt: unsigned;
  bufIndexes: array[0..c_maxPSBufs - 1] of unsigned;
  bufIndexesCnt: unsigned;
  sleepBeforeNextLock: bool;
  nextMinSeq: int64;
  nextMinSeq2: int64;
  sn: int64;
begin
{$IFDEF LOG_SOCKS_THREADS }
  logMessage(_classID + '.execute() - ENTER');
{$ENDIF }
  //
{$IFDEF VCX_DEMO }
  // we are running demo version, and so no thread priority will be set
  // but with this thread priority must always be set, so do it here
  SetThreadPriority(getHandle(), THREAD_PRIORITY_TIME_CRITICAL);
{$ELSE }
  // not a demo version, so thread priority already set in constructor
{$ENDIF }
  //
  while (not shouldStop) do begin
    //
    try
      sleepBeforeNextLock := false;
      //
      if (sleepThread(200) and not shouldStop and (0 < f_bufCount)) then begin
	//
	//
	if (f_bufLock.enter(20)) then try
	  //
	  nextMinSeq := $7FFFFFFFFFFFFFFF;
	  bufIndexesCnt := 0;
	  i := 0;
	  while (not shouldStop and (i < f_bufCount)) do begin
	    //
	    if (1 = f_buffers[i].r_flags) then begin
	      //
	      if (0 < f_buffers[i].r_dataSizeUsed) then begin
		//
		if (nextMinSeq > f_buffers[i].r_seqNum) then
		  nextMinSeq := f_buffers[i].r_seqNum;
		//
		bufIndexes[bufIndexesCnt] := i;
		inc(bufIndexesCnt);
	      end
	      else
		bufferRelease(@f_buffers[i]);	// buffer has no data, release it
	      //
	    end;
	    //
	    inc(i);
	  end;
	  //
	  cnt := 0;
	  while ((cnt < bufIndexesCnt) and (cnt < 4)) do begin	// do not notify more than 3 buffers per one lock
	    //
	    // must notify buffers in proper order, starting from nextMinSeq
	    i := 0;
	    nextMinSeq2 := $7FFFFFFFFFFFFFFF;
	    while (not shouldStop and (i < bufIndexesCnt)) do begin
	      //
	      if (unsigned(-1) <> bufIndexes[i]) then begin
		//
		sn := f_buffers[bufIndexes[i]].r_seqNum;
		if (sn = nextMinSeq) then begin
		  //
		  // notify this buffer
		  with (f_buffers[bufIndexes[i]]) do begin
		    //
		    f_masterThread.f_socks.event(f_masterEventType, f_masterThread.id, r_connId or ($7F shl 24), r_data, r_dataSizeUsed);
		    //
		    // mark this buffer as free
		    bufferRelease(@f_buffers[bufIndexes[i]]);
		    //
		    bufIndexes[i] := unsigned(-1);	// this buffer no longer will be considered
		  end;
		end
		else begin
		  //
		  if (nextMinSeq2 > sn) then
		    nextMinSeq2 := sn;
		end;
	      end;
	      //
	      inc(i);
	    end;
	    //
	    nextMinSeq := nextMinSeq2;
	    //
	    inc(cnt);
	  end;
	  //
	  if (2 <= cnt) then begin
	    //
	    sleepBeforeNextLock := true;
	    wakeUp();	// handle rest of buffers in next loop
	  end;
	  //
	finally
	  f_bufLock.leave();
	end
	else begin
	  //
	  wakeUp();	// try one more time
	end;
	//
      end;
      //
      if (sleepBeforeNextLock) then
	Sleep(10);	// we already woke up, so sleep a little before we go to next lock to give other threads a chance to lock bufs
      //
    except
      // ignore exceptions
    end;
  end;
  //
  //mrealloc(f_packetBuf);
  //f_packetBufSize := 0;
  //
  result := 0;
  //
{$IFDEF LOG_SOCKS_THREADS }
  logMessage(_classID + '.execute() - EXIT');
{$ENDIF }
end;

// --  --
function unaSocksPacketStormThread.newPacket(connId: unsigned; buf: punaPacketStormBuffer): bool;
begin
  if (f_bufLock.enter(100)) then try
    //
    result := ((2 = buf.r_flags) and (buf.r_dataSizeUsed <= buf.r_dataSize));
    if (result) then begin
      //
      if (0 < buf.r_dataSizeUsed) then begin
	//
	buf.r_flags := 1;	// now it officially has data
	buf.r_connId := connId;
      end
      else
	buf.r_flags := 0;	// no data, mark it as free
      //
      if (1 = buf.r_flags) then
	wakeUp();
      //	
    end;
  finally
    f_bufLock.leave();
  end
  else
    result := false;
end;

// --  --
procedure unaSocksPacketStormThread.removeConnection(connId: unsigned);
var
  i: unsigned;
begin
{$IFDEF LOG_SOCKS_THREADS }
  logMessage(_classID + '.removeStream(' + int2str(connId) + ') - ENTER');
{$ENDIF }
  //
  if (f_bufLock.enter(100)) then try
    //
    if (0 < f_bufCount) then begin
      //
      for i := 0 to f_bufCount - 1 do begin
	//
	if ((1 = f_buffers[i].r_flags) and (connId = f_buffers[i].r_connId)) then
	  f_buffers[i].r_flags := 0;
      end;
    end;
  finally
    f_bufLock.leave();
  end;
  //
{$IFDEF LOG_SOCKS_THREADS }
  logMessage(_classID + '.removeStream(' + int2str(connId) + ') - EXIT');
{$ENDIF }
end;


{ unaSocksThread }

// --  --
procedure unaSocksThread.BeforeDestruction();
begin
{$IFDEF LOG_SOCKS_THREADS }
  logMessage(_classID + '.BeforeDestruction() - trying hard to stop the thread (for at least 30 sec)..');
{$ENDIF }
  //
  stop(30000);	// try hard to stop the thread, socket operation may take some time..
  //
{$IFDEF LOG_SOCKS_THREADS }
  logMessage(_classID + '.BeforeDestruction() - probably stopped now, falling down to inherited..');
{$ENDIF }
  //
  inherited;
end;

// --  --
function unaSocksThread.checkSocketError(errorCode: integer; addr: pSockAddrIn; allowThreadStop: bool): bool;
var
  index: integer;
  connection: unaSocksConnection;
  wasAcq: bool;
begin
  if (isServer and (nil <> addr)) then begin
    //
    // UDP peer failure
    if (0 <> addr.sin_addr.s_addr) then begin
      //
      index := -1;
      //
      wasAcq := true;
      connection := getConnectionByAddr(addr^, true);
      if (nil = connection) then begin
	//
	connection := getConnectionByAddr(addr^, false);
	wasAcq := false;
      end;
      //
      if (nil <> connection) then
	try
	  index := connections.indexOfId(connection.connId)
	finally
	  //
	  if (wasAcq) then
	    connection.release();
	end;
      //
      if (0 <= index) then begin
	//
{$IFDEF LOG_UNASOCKETS_INFOS }
	logMessage(_classID + '.checkSocketError() - UDP connection is about to be removed due to socket error=' + int2str(errorCode));
{$ENDIF LOG_UNASOCKETS_INFOS }
	connections.removeByIndex(index);
      end;
    end;
  end;
  //
  result := false;	// indicate non-fatal error
  case (errorCode) of

    WSAEINVAL,
    //WSA_OPERATION_ABORTED,
    WSANOTINITIALISED,
    WSAEHOSTDOWN,
    WSAECONNABORTED,
    WSAECONNRESET,
    WSAENETDOWN,
    WSAENETUNREACH,
    WSAENETRESET,
    //WSAEFAULT,	-- this error is not fatal, as it can happen when client socket dies unexpectedly
    WSAENOTSOCK,
    WSAESHUTDOWN,
    //
    ERROR_NO_NETWORK,
    ERROR_CANCELLED,
    ERROR_CONNECTION_REFUSED,
    ERROR_GRACEFUL_DISCONNECT,
    ERROR_CONNECTION_INVALID,
    ERROR_NETWORK_UNREACHABLE,
    ERROR_HOST_UNREACHABLE,
    ERROR_PROTOCOL_UNREACHABLE,
    ERROR_PORT_UNREACHABLE,
    ERROR_REQUEST_ABORTED,
    ERROR_CONNECTION_ABORTED,
    ERROR_CONNECTION_COUNT_LIMIT,
    ERROR_INCORRECT_ADDRESS,
    ERROR_SERVICE_NOT_FOUND

    : begin
      //
      if (allowThreadStop) then begin
	//
	f_socketError := errorCode;
	askStop();
      end;
      //
      result := true;
    end;

    else
      ; // assume non-fatal error, do nothing

  end;	// case
end;

// --  --
constructor unaSocksThread.create(socks: unaSocks; id: unsigned);
begin
  f_socks := socks;
  f_id := id;
  //
  f_connections := unaSocketsConnections.create(uldt_obj);
  //
  f_initDone := unaEvent.create(true);
  //
  inherited create(false);
end;

// --  --
destructor unaSocksThread.destroy();
begin
{$IFDEF LOG_SOCKS_THREADS }
  logMessage(_classID + '.destroy() - About to destroy..');
{$ENDIF }
  //
  freeAndNil(f_connections);
  freeAndNil(f_initDone);
  //
  inherited;
  //
{$IFDEF LOG_SOCKS_THREADS }
  logMessage(_classID + '.destroy() - Destroy done.');
{$ENDIF }
end;

// --  --
function unaSocksThread.doGetRemoteHostAddr(connId: unsigned): pSockAddrIn;
var
  conn: unaSocksConnection;
begin
  if (isServer) then
    conn := getConnection(connId)
  else
    conn := f_connections[0];	// client thread has only one connection
  //
  if (nil <> conn) then
    result := conn.paddr
  else
    result := nil;  
end;

// --  --
function unaSocksThread.execute(globalIndex: unsigned): int;
const
  cWaitTimeout	= 40;	// time slice (in ms) given to a Server to check all client connections
var
  i: int;
  newSocket: unaSocket;
  index: integer;
  noData: bool;
  ok: bool;
  error: integer;
  //
  dataBuf: punaPacketStormBuffer;
  dataBufSize: unsigned;
  maxDataSize: unsigned;
  //
  addr: sockaddr_in;
  connection: unaSocksConnection;
  waitForDataTimeout: unsigned;
  //
  wasAcq: bool;
  //
  udpTimeoutTestIndex: int;
begin
{$IFDEF LOG_SOCKS_THREADS }
  logMessage(_classID + '.execute() - ENTER');
{$ENDIF }
  //
  udpTimeoutTestIndex := 0;
  newConnId(4000);
  //
  connection := nil;
  f_initDone.setState(false);
  //
  f_psThread := unaSocksPacketStormThread.create(self);
  //
  try
    if (f_isServer) then begin
      //
      // TCP/UDP server
      //
      case (threadSocket.socketProtocol) of

	IPPROTO_UDP: begin
	  //
	  // UDP SERVER INIT
	  f_socketError := threadSocket.bindSocketToPort(threadSocket.getPortInt());
	  ok := (0 = f_socketError);
	  ok := ok and threadSocket.isActive;
	end;

	IPPROTO_TCP: begin
	  //
	  // TCP SERVER INIT
	  f_socketError := threadSocket.listen(f_backlog);
	  ok := (0 = f_socketError);
	  ok := ok and threadSocket.isActive;
	end;

	else
	  ok := false;

      end;
      //
      if (ok) then begin
	//
	f_socks.event(unaseThreadAdjustSocketOptions, id, threadSocket.getSocket(), pointer(1));	// data <> nil means "main" socket
	//
	f_socks.event(unaseServerListen, id, 0);	// notify server starts listening,
      end;
      //
    end
    else begin
      //
      // UDP/TCP CLIENT
      //
      // this could take a while..  
      f_socketError := threadSocket.connect();
      //
      ok := (0 = f_socketError);
      if (not shouldStop) then begin
	//
	if (ok) then
	  connection := unaSocksConnection.create(self, f_lastConnectionIdInt, threadSocket);
	//
	if (nil <> connection) then
	  connections.add(connection);
      end;
      //
      newConnId();
    end;

    //
    if (not shouldStop) then begin
      //
      f_initDone.setState(true);
      //
      f_psThread.start();
    end;

{$IFDEF LOG_SOCKS_THREADS }
    logMessage(_classID + '.execute() - Before main loop, ok=' + bool2strStr(ok));
{$ENDIF }

    //
    if (ok) then begin
      //
      if (IPPROTO_UDP = threadSocket.socketProtocol) then
	maxDataSize := 4096
      else
	maxDataSize := threadSocket.getMTU();
      //
      //data := malloc(maxDataSize);
      //
      // notify client we are connected
      if (not f_isServer and (nil <> connection)) then begin
	//
	f_socks.event(unaseThreadAdjustSocketOptions, id, threadSocket.getSocket(), pointer(1));	// data <> nil means "main" socket
	//
	f_socks.event(unaseClientConnect, id, connection.connId);
      end;
      //
      waitForDataTimeout := cWaitTimeout;
      //
      while (not shouldStop) do begin
	//
	try
	  //
	  if (f_isServer) then begin
	    //
	    case (threadSocket.socketProtocol) of


	      IPPROTO_UDP: begin
		//
		// ====--- UDP SERVER ---====
		//
		if (not threadSocket.check_error(1) and threadSocket.waitForData(waitForDataTimeout, false)) then begin
		  //
		  addr.sin_addr.s_addr := 0;
		  dataBuf := unaSocksPacketStormThread(f_psThread).bufferGet(maxDataSize);
		  if (nil <> dataBuf) then begin
		    //
		    error := unaUdpSocket(threadSocket).recvfrom(addr, dataBuf.r_data, maxDataSize, true, 0, cWaitTimeout);
		    if (0 < error) then begin
		      //
		      {$IFDEF LOG_RAW_DATA_PACKETS }
		      logMessage('UNA_SOCKETS: UDP SERVER / new packet, size=' + int2str(error) + '; CRC32=' + int2str(crc32(data, error), 16));
		      {$ENDIF }
		      // new data from client
		      dataBuf.r_dataSizeUsed := error;
		      waitForDataTimeout := 1;	// next time do quick checks, we are in hurry
		      //
		      wasAcq := true;
		      connection := getConnectionByAddr(addr, true);
		      if (nil = connection) then begin
			//
			connection := getConnectionByAddr(addr, false);
			wasAcq := false;
		      end;
		      //
		      if (nil = connection) then begin
			//
			{$IFDEF LOG_RAW_DATA_PACKETS }
			logMessage('UNA_SOCKETS: UDP SERVER / new connection!');
			{$ENDIF }
			//
			connection := unaSocksConnection.create(self, newConnId(), threadSocket, @addr);
			connections.add(connection);
			//
			// Connection may be removed in event handler / Lake, Jan'08
			f_socks.event(unaseServerConnect, id, connection.connId, @addr, sizeOf(addr));	// @addr, sizeOf(addr) params were added by Lake, 01 October 2003
			//
			if ((0 > connections.indexOf(connection)) or not connection.acquire(155)) then
			  connection := nil
			else
			  wasAcq := true;
			//
		      end;
		      //
		      if (nil = connection) then begin
			//
			{$IFDEF LOG_UNASOCKETS_ERRORS }
			logMessage(self._classID + '.execute() - got no connection :(');
			{$ENDIF LOG_UNASOCKETS_ERRORS }
                        //
                        unaSocksPacketStormThread(f_psThread).bufferRelease(dataBuf);
		      end
		      else begin
			//
			try
			  //f_socks.event(unaseServerData, id, connection.connId, @data[1], length(data));
			  //{HACK}infoMessage('SOCKET THREAD: connId #' + int2str(connection.connId) + ' got packet #' + int2str(byte(data[1])));
			  connection.resetTimeout();
			  unaSocksPacketStormThread(f_psThread).newPacket(connection.connId, dataBuf);
			finally
			  if (wasAcq) then
			    connection.release();
			end;
		      end;
		    end
		    else begin
		      //
		      unaSocksPacketStormThread(f_psThread).bufferRelease(dataBuf);
		      //
		      case (error) of

			SOCKET_ERROR:
			  checkSocketError(checkError(error, true {$IFDEF DEBUG}, 'socks thread, UDP server'{$ENDIF}), @addr, false);

			0: // the connection has been gracefully closed
			  checkSocketError(WSAECONNRESET, @addr, false);

		      end;
		      //
		      Sleep(10);
		      //
		      waitForDataTimeout := cWaitTimeout;
		    end;
		  end;	// if (nil <> dataBuf) ...
		  //
		end
		else begin
		  //
		  waitForDataTimeout := cWaitTimeout;
		  //
		  // quick test for UDP timeouts (if needed)
		  if ((0 < udpConnectionTimeout) and connections.lock(10)) then begin
		    //
		    try
		      inc(udpTimeoutTestIndex);
		      //
		      if (udpTimeoutTestIndex >= connections.count) then
			udpTimeoutTestIndex := 0;
		      //
		      if (udpTimeoutTestIndex < connections.count) then begin
			//
			connection := connections[udpTimeoutTestIndex];
			if (connection.getTimeout() > udpConnectionTimeout) then
			  // time to remove this connection due to no data trasnfer timeout
			  connections.removeByIndex(udpTimeoutTestIndex);
			//
		      end;
		      //
		    finally
		      connections.unlock();
		    end;
		  end;
		  //
		end;
	      end;


	      IPPROTO_TCP: begin
		//
		// ====--- TCP SERVER ---====
		//
		try
		  if (0 < connections.count) then
		    // we have some connections already, lets do a quick accept test
		    newSocket := threadSocket.accept(error, 1)	// 1 ms. delay
		  else begin
		    // we have no connections yet, lets do a long accept test
		    {$IFDEF LOG_RAW_DATA_PACKETS }
		    //logMessage('UNA_SOCKETS: TCP SERVER --------- DOING LONG ACCEPT ---------');
		    {$ENDIF }
		    newSocket := threadSocket.accept(error, cWaitTimeout);	// long delay
		  end;
		  //
		  if (nil <> newSocket) then begin
		    // add new connection
		    {$IFDEF LOG_RAW_DATA_PACKETS }
		    logMessage('UNA_SOCKETS: TCP SERVER / new connection!');
		    {$ENDIF }
		    //
		    connection := unaSocksConnection.create(self, newConnId(), newSocket);
		    connections.add(connection);
		    //
		    f_socks.event(unaseThreadAdjustSocketOptions, id, newSocket.getSocket(), nil);	// data = nil means "client" socket
		    //
		    f_socks.event(unaseServerConnect, id, connection.connId);
		    connection := nil;
		  end
		  else begin
		    //
		    if (WSAETIMEDOUT <> error) then
		      checkSocketError(error, nil, true);	// could be some fatal problem with listening socket, so stop the thread if needed
		  end;
		except
		  //
		end;
		//
		noData := true;
		try
		  i := 0;
		  while (i < connections.count) do begin
		    //
		    connection := connections[i];
		    if ((nil <> connection) and not connection.f_destroying {and connection.acquire(10)}) then try
		      //
		      newSocket := connection.f_threadSocket;
		      //
		    {$IFDEF LOG_RAW_DATA_PACKETS }
		      logMessage('UNA_SOCKETS: TCP SERVER / checking connection with connId=' + int2str(connection.connId) + '; WDT=' + int2str(waitForDataTimeout) + '; error=' + int2str(error));
		    {$ENDIF }
		      //
		      if (not newSocket.check_error(1) and newSocket.waitForData(waitForDataTimeout, false)) then begin
			// read data from socket
			//
			//dataSize := maxDataSize;
			dataBuf := unaSocksPacketStormThread(f_psThread).bufferGet(maxDataSize);
			if (nil <> dataBuf) then begin
			  //
			  index := -1;
			  dataBufSize := maxDataSize;
			  error := newSocket.read(dataBuf.r_data, dataBufSize, 1, true);
			  if (0 = error) then begin
			    //
			    if (0 < dataBufSize) then begin
			      //
		      {$IFDEF LOG_RAW_DATA_PACKETS }
			      logMessage('UNA_SOCKETS: TCP SERVER / new data chunk for connId=' + int2str(connection.connId) + '; size=' + int2str(dataSize) + '; CRC32=' + int2str(crc32(data, dataSize), 16));
		      {$ENDIF }
			      //
			      waitForDataTimeout := 1;	// switch to quick checks, we are in hurry
			      noData := false;
			      //
			      //f_socks.event(unaseServerData, id, connection.connId, @data[1], length(data));
			      dataBuf.r_dataSizeUsed := dataBufSize;
			      unaSocksPacketStormThread(f_psThread).newPacket(connection.connId, dataBuf);
			    end
			    else begin
			      // request to close the socket has been received from the peer
			      unaSocksPacketStormThread(f_psThread).bufferRelease(dataBuf);
			      //
			      if (checkSocketError(WSAESHUTDOWN, nil, false)) then
				index := i;
			      //
			    end;
			  end
			  else begin
			    // some error occured
			    //
			    unaSocksPacketStormThread(f_psThread).bufferRelease(dataBuf);
			    //
			    if (0 > error) then
			      // no data for some reason
			    else begin
			      // mark error code and remove connection
			      if (checkSocketError(error, nil, false)) then
				index := i;	// remote this connection
			      //
			    end;
			  end;  //
			  //
			  if (0 <= index) then begin
			    //
      {$IFDEF LOG_UNASOCKETS_INFOS }
			    logMessage(_classID + '.execute() - connection is about to be removed, index=' + int2str(i));
      {$ENDIF LOG_UNASOCKETS_INFOS }
			    //
			    //connection.release();
			    connection := nil;
			    connections.removeByIndex(i);
			    //
			    break;
			  end;
			end;
			//
		      end; // can read something
		      //
		    finally
		      //if (nil <> connection) then
			//connection.release();
		    end
		    else begin
		      //
		      if (nil = connection) then begin
			//
  {$IFDEF LOG_UNASOCKETS_INFOS }
			logMessage(_classID + '.execute() - connection is about to be removed, index=' + int2str(i));
  {$ENDIF LOG_UNASOCKETS_INFOS }
			connections.removeByIndex(i);
		      end;
		    end;
		    //
		    inc(i);
		  end; // while (i < connections.count) do ...
		  //
		except
		end;
		//
		if (noData) then begin
		  //
		  if (2 > connections.count) then
		    waitForDataTimeout := cWaitTimeout
		  else
		    waitForDataTimeout := cWaitTimeout div (connections.count);
		  //
		end;
		//
	      end;


	      else	// case
		;

	    end;	// CASE

	  end
	  else begin
	    //
	    // -- is client --
	    //
	    case (threadSocket.socketProtocol) of

	      IPPROTO_TCP: begin
		//
		// TCP CLIENT
		//
		if (not threadSocket.check_error(1) and threadSocket.waitForData(waitForDataTimeout, false)) then begin
		  //
		  //dataSize := maxDataSize;
		  dataBuf := unaSocksPacketStormThread(f_psThread).bufferGet(maxDataSize);
		  if (nil <> dataBuf) then begin
		    //
		    dataBufSize := maxDataSize;
		    error := threadSocket.read(dataBuf.r_data, dataBufSize, 1, true);
		    if (0 = error) then begin
		      //
		      if (0 < dataBufSize) then begin
			//
			{$IFDEF LOG_RAW_DATA_PACKETS }
			logMessage('UNA_SOCKETS: TCP CLIENT / new data chunk, size=' + int2str(dataBufSize) + '; CRC32=' + int2str(crc32(dataBuf, dataBufSize), 16));
			{$ENDIF }
			{$IFDEF LOG_RAW_DATA_PACKETS2 }
			logMessage('UNA_SOCKETS: TCP CLIENT / new data chunk, size=' + int2str(dataBufSize) + '; CRC32=' + int2str(crc32(dataBuf, dataBufSize), 16));
			{$ENDIF }
			//
			waitForDataTimeout := 1;	// quick cheks, we are in hurry
			//
			dataBuf.r_dataSizeUsed := dataBufSize;
			unaSocksPacketStormThread(f_psThread).newPacket(connection.connId, dataBuf);
		      end
		      else begin
			//
			unaSocksPacketStormThread(f_psThread).bufferRelease(dataBuf);
			//
			// request to close the socket has been received from remote peer
			// and since now we have only one socket per thread - stop the whole thead
			checkSocketError(WSAESHUTDOWN, nil, true);
		      end;
		      //
		    end
		    else begin
		      //
		      unaSocksPacketStormThread(f_psThread).bufferRelease(dataBuf);
		      //
		      if (0 > error) then
			// no data for some reason
			waitForDataTimeout := cWaitTimeout
		      else
			// analyze error code
			checkSocketError(error, nil, true);
		    end;
		  end;	// if (nil <> dataBuf) ..
		end
		else
		  waitForDataTimeout := cWaitTimeout;
		//
	      end;


	      IPPROTO_UDP: begin
		//
		// UDP CLIENT
		//
		if (not threadSocket.check_error(1) and threadSocket.waitForData(waitForDataTimeout, false)) then begin
		  //
		  dataBuf := unaSocksPacketStormThread(f_psThread).bufferGet(maxDataSize);
		  if (nil <> dataBuf) then begin
		    //
		    error := unaUdpSocket(threadSocket).recvfrom(addr, dataBuf.r_data, maxDataSize, true);
		    if (0 < error) then begin
		      //
		      // new data for client
		      {$IFDEF LOG_RAW_DATA_PACKETS }
		      logMessage('UNA_SOCKETS: UDP CLIENT / new data chunk, size=' + int2str(dataSize) + '; CRC32=' + int2str(crc32(data, dataSize), 16));
		      {$ENDIF }
		      //
		      dataBuf.r_dataSizeUsed := error;
		      waitForDataTimeout := 1;	// quick checks, we are in hurry
		      //
		      //f_socks.event(unaseClientData, id, connection.connId, @data[1], length(data))
		      unaSocksPacketStormThread(f_psThread).newPacket(connection.connId, dataBuf);
		    end
		    else begin
		      //
		      unaSocksPacketStormThread(f_psThread).bufferRelease(dataBuf);
		      //
		      case (error) of

			SOCKET_ERROR:
			  checkSocketError(checkError(error, true {$IFDEF DEBUG}, 'socks thread, UDP client'{$ENDIF}), nil, true);

			0: // the connection has been gracefully closed
			   // since that was our main socket - stop the whole thread
			  checkSocketError(WSAESHUTDOWN, nil, true);

			else
			  waitForDataTimeout := cWaitTimeout;

		      end; // case
		    end;
		  end;	// if (nil <> dataBuf) ..  
		  //
		end
		else
		  waitForDataTimeout := cWaitTimeout;

	      end;

	    end;	// CASE

	  end;	// else (if client/server )

	except
	// ignore exceptions
	end;
	//
      end;	// WHILE (NOT SHOULDSTOP)
      //
    end
    else begin // if (ok) ..
      //
      if (nil <> connection) then
	f_socks.event(unaseThreadStartupError, id, connection.connId)
      else
	f_socks.event(unaseThreadStartupError, id, f_lastConnectionIdInt - 1);
      //
    end;

    //
  finally
    //
{$IFDEF LOG_SOCKS_THREADS }
    logMessage(_classID + '.execute() - Finally..');
{$ENDIF LOG_SOCKS_THREADS }
    //
    freeAndNil(f_psThread);
    //
    if (not f_isServer) then
      f_socks.event(unaseClientDisconnect, id, f_lastConnectionIdInt - 1);
    //
    try
      connections.clear();
      //
      if (f_isServer) then
	f_socks.event(unaseServerStop, id, 0);
      //
    except
      // ignore all exceptions
    end;
    //
    // release socket
    releaseSocket();
    //
    // reset state
    f_initDone.setState(false);
  end;
  //
  result := 0;
  //
{$IFDEF LOG_SOCKS_THREADS }
  logMessage(_classID + '.execute() - EXIT');
{$ENDIF }
end;

// --  --
function unaSocksThread.getConnection(connId: unsigned; timeout: unsigned): unaSocksConnection;
begin
  result := connections.get_connection(connId, timeout);
  //
  {$IFDEF LOG_UNASOCKETS_ERRORS }
  if (nil = result) then
    logMessage(self._classID + '.getConnection() - no connection with id=' + int2str(connId));
  {$ENDIF LOG_UNASOCKETS_ERRORS }
end;

// --  --
function unaSocksThread.getConnectionByAddr(const addr: sockaddr_in; needAcquire: bool): unaSocksConnection;
var
  i: int;
begin
  result := nil;
  i := 0;
  if (connections.lock(1090)) then begin
    //
    try
      while (i < connections.count) do begin
	//
	result := connections.get(i);
	if (result.compareAddr(addr)) then
	  break
	else
	  result := nil;
	//
	inc(i);
      end;
      //
      if ((nil <> result) and needAcquire) then begin
	//
	if (not result.acquire(130)) then begin
{$IFDEF LOG_UNASOCKETS_ERRORS }
	  logMessage(_classID + '.getConnectionByAddr() - cannot acquire the connection.');
{$ENDIF LOG_UNASOCKETS_ERRORS }
	  result := nil;
	end;
      end;
      //
    finally
      connections.unlock();
    end;
  end
  else begin
    //
{$IFDEF LOG_UNASOCKETS_ERRORS }
    logMessage(_classID + '.getConnectionByAddr() - cannot enter the gate, new connection will be created..');
{$ENDIF LOG_UNASOCKETS_ERRORS }
    result := nil;
  end;
end;

// --  --
function unaSocksThread.getRemoteHostAddr(connId: unsigned): pSockAddrIn;
begin
  result := doGetRemoteHostAddr(connId);
end;

// --  --
function unaSocksThread.newConnId(initialValue_delta: int): unsigned;
begin
  if (0 < initialValue_delta) then begin
    //
    f_lastConnectionIdInt := initialValue_delta;
    result := initialValue_delta;
  end
  else begin
    //
    if (0 = initialValue_delta) then
      result := f_lastConnectionIdInt
    else
      result := InterlockedIncrement(f_lastConnectionIdInt);
  end;    
end;

// --  --
procedure unaSocksThread.onConnectionRemove(connId: unsigned);
begin
{$IFDEF LOG_UNASOCKETS_INFOS }
  logMessage(_classID + '.onConnectionRemove() - master connection [' + int2str(connId) + '] is about to be removed from server..');
{$ENDIF LOG_UNASOCKETS_INFOS }
  //
  if (nil <> f_psThread) then
    unaSocksPacketStormThread(f_psThread).removeConnection(connId);
  //
  if (f_isServer) then
    f_socks.event(unaseServerDisconnect, id, connId);
end;

// --  --
procedure unaSocksThread.releaseSocket();
begin
  freeAndNil(f_socket);
end;

// --  --
function unaSocksThread.sendDataTo(connId: unsigned; data: pointer; len: unsigned; out asynch: bool; timeout: unsigned): int;
begin
  result := WSAENOTCONN; // reserved for IOCP threads
end;



{ unaSocksThreads }

// --  --
function unaSocksThreads.getId(item: pointer): int64;
begin
  result := unaSocksThread(item).id;
end;



{ unaSocks }

// --  --
function unaSocks.activate(id: unsigned): bool;
var
  thread: unaSocksThread;
begin
  thread := getThreadByID(id);
  //
  if (nil <> thread) then
    result := thread.start()
  else
    result := false;
end;

// --  --
procedure unaSocks.clear(clearServers: bool; clearClients: bool);
var
  i: int;
  thread: unaSocksThread;
begin
  i := 0;
  while (i < f_threads.count) do begin
    //
    thread := getThreadByIndex(i);
    //
    if ((clearServers and thread.f_isServer) or
	(clearClients and not thread.f_isServer)) then
      closeThread(thread.id);
    //
    inc(i);
  end;
end;

// --  --
function unaSocks.closeThread(id: unsigned; timeout: int): bool;
var
  thread: unaSocksThread;
begin
  result := false;
  //
  if (enter(timeout)) then begin
    //
    try
      //
      thread := getThreadById(id, timeout);
      //
      result := (nil <> thread);
      if (result) then
	thread.stop(timeout)
      else begin
	//
	{$IFDEF LOG_UNASOCKETS_ERRORS }
	logMessage(self._classID + '.closeThread() - cannot get thread with id=' + int2str(id));
	{$ENDIF LOG_UNASOCKETS_ERRORS }
      end;
      //
    finally
      leave();
    end;
  end;
end;

// --  --
constructor unaSocks.create(threadsInPool: unsigned {$IFDEF VC25_IOCP }; isIOCP: bool{$ENDIF VC25_IOCP });
begin
  inherited create();
  //
  if (g_unaWSAGateReady) then begin
    //
    if (g_unaWSAGate.enter(1000)) then begin
      try
	f_master := (nil = g_unaWSA);
	//
	if (f_master) then
	  unaSockets.startup();
	//
      finally
	g_unaWSAGate.leave();
      end;
    end;
    //
  end;
  //
  f_gate := unaInProcessGate.create({$IFDEF DEBUG}_classID + '(f_gate)'{$ENDIF});
  f_threads := unaSocksThreads.create(uldt_obj);
  f_threads.timeOut := 1000;
  //
  f_lastThreadID := 72;
  //
{$IFDEF VC25_IOCP }
  self.isIOCP := isIOCP;
{$ENDIF VC25_IOCP }
  //
  setPoolSize(threadsInPool);
end;

// --  --
function unaSocks.createConnection(const host, port: string; protocol: int; activate: bool; const bindToIP, bindToPort: string{$IFDEF VC25_OVERLAPPED }; overlapped: bool{$ENDIF }): unsigned;
var
  socket: unaSocket;
  thread: unaSocksThread;
begin
  result := 0;
  //
  if (f_threads.lock(1000)) then begin
    try
      thread := getThreadFromPool();
      if (nil <> thread) then begin
	//
	socket := createSocket(protocol {$IFDEF VC25_OVERLAPPED }, overlapped{$ENDIF });
	if (nil <> socket) then begin
	  //
	  socket.setHost(host);
	  socket.setPort(port);
	  socket.bindToIP := bindToIP;
	  socket.bindToPort := bindToPort;
	  //
	  thread.f_socket := socket;
	  thread.f_isServer := false;
	  thread.priority := THREAD_PRIORITY_HIGHEST;	// boost client
	  //
	  if (activate) then
	    thread.start();
	  //
	  result := thread.id;
	end;
      end;
      //
    finally
      f_threads.unlock();
    end;
  end;
end;

// --  --
function unaSocks.createServer(const port: string; protocol: int; activate: bool; backlog: int; udpConnectionTimeout: unsigned; const bindToIP: string{$IFDEF VC25_OVERLAPPED }; overlapped: bool{$ENDIF }): unsigned;
var
  socket: unaSocket;
  thread: unaSocksThread;
begin
  result := 0;
  //
  if (lockNonEmptyList(f_threads, 1000)) then begin
    try
      thread := getThreadFromPool();
      //
      if (nil <> thread) then begin
	//
	socket := createSocket(protocol {$IFDEF VC25_OVERLAPPED }, overlapped{$ENDIF });
	if (nil <> socket) then begin
	  //
	  socket.setPort(port);
	  socket.bindToIP := bindToIP;
	  //socket.bindToPort := bindToPort;
	  //
	  thread.f_socket := socket;
	  thread.f_isServer := true;
	  thread.f_backlog := backlog;
	  thread.f_udpConnectionTimeout := udpConnectionTimeout;
	  //
	  thread.priority := THREAD_PRIORITY_TIME_CRITICAL;	// boost server even more
	  //
	  if (activate) then
	    thread.start();
	  //
	  result := thread.id;
	end;
      end;
      //
    finally
      f_threads.unlock();
    end;
  end;
end;

// --  --
function unaSocks.createSocket(protocol: int{$IFDEF VC25_OVERLAPPED }; overlapped: bool{$ENDIF VC25_OVERLAPPED }): unaSocket;
begin
  case (protocol) of

    IPPROTO_UDP:
      result := unaUdpSocket.create({$IFDEF VC25_OVERLAPPED }overlapped{$ENDIF });

    IPPROTO_TCP:
      result := unaTcpSocket.create({$IFDEF VC25_OVERLAPPED }overlapped{$ENDIF });

    else
      result := nil;	// unknown proto

  end;
end;

// -- --
destructor unaSocks.destroy();
begin
{$IFDEF LOG_SOCKS_THREADS }
  logMessage(_classID + '.destroy() - About to destroy..');
{$ENDIF }
  clear(true, true);
  //
  freeAndNil(f_threads);
  //
  freeAndNil(f_gate);
  //
  if (f_master) then
    unaSockets.shutdown();
  //
  inherited;
  //
{$IFDEF LOG_SOCKS_THREADS }
  logMessage(_classID + '.destroy() - done.');
{$ENDIF }
end;

// --  --
function unaSocks.enter(timeout: unsigned): bool;
begin
  result := f_gate.enter(timeout{$IFDEF DEBUG}, _classID{$ENDIF});
end;

// --  --
procedure unaSocks.event(event: unaSocketEvent; id, connId: unsigned; data: pointer; size: unsigned);
begin
  if (assigned(f_onEvent)) then
    f_onEvent(self, event, id, connId, data, size);
end;

// --  --
function unaSocks.getConnection(id, connId: unsigned; timeout: unsigned; needAcquire: bool): unaSocksConnection;
var
  thread: unaSocksThread;
begin
  thread := getThreadByID(id, timeout + 1);
  //
  {$IFDEF LOG_UNASOCKETS_ERRORS }
  if (nil = thread) then
    logMessage(self._classID + '.getConnection() - there is no thread with id=' + int2str(id) + '; connId=' + int2str(connId));
  {$ENDIF LOG_UNASOCKETS_ERRORS }
  //
  if (nil <> thread) then
    result := thread.getConnection(connId, timeout)
  else
    result := nil;
  //
  if ((nil <> result) and needAcquire) then begin
    //
    if (not result.acquire(timeout)) then begin
      //
      result := nil;
    end;
  end;
end;

// --  --
function unaSocks.getRemoteHostAddr(id, connId: unsigned): pSockAddrIn;
var
  thread: unaSocksThread;
begin
  thread := getThreadByID(id);
  if (nil <> thread) then
    result := thread.getRemoteHostAddr(connId)
  else
    result := nil;
end;

// --  --
function unaSocks.getRemoteHostInfo(id, connId: unsigned; out ip, port: string): bool;
var
  proto: int;
begin
  result := getRemoteHostInfoEx(id, connId, ip, port, proto);
end;

// --  --
function unaSocks.getRemoteHostInfo(addr: pSockAddrIn; out ip, port: string): bool;
begin
  if (nil <> addr) then begin
    //
    ip := string(inet_ntoa(addr.sin_addr));
    port := int2str(htons(u_short(addr.sin_port)));
    //
    result := true;
  end
  else
    result := false;
end;

// --  --
function unaSocks.getRemoteHostInfoEx(id, connId: unsigned; out ip, port: string; out proto: int): bool;
var
  addr: pSockAddrIn;
  thread: unaSocksThread;
begin
  result := false;
  //
  addr := getRemoteHostAddr(id, connId);
  if (nil <> addr) then begin
    //
    getRemoteHostInfo(addr, ip, port);
    //
    thread := getThreadByID(id);
    if ((nil <> thread) and (nil <> thread.threadSocket)) then
      proto := thread.threadSocket.socketProtocol
    else
      proto := 0;
    //
    result := true;
  end;
end;

// --  --
function unaSocks.getSocketError(id: unsigned; needLock: bool): int;
var
  thread: unaSocksThread;
begin
  if (not needLock or (needLock and f_threads.lock(500))) then begin
    try
      thread := getThreadById(id);
      //
      if (nil <> thread) then
	result := thread.socketError
      else
	result := 0;
      //
    finally
      if (needLock) then
	f_threads.unlock();
    end;
  end
  else
    result := -1;
end;

// --  --
function unaSocks.getThreadByID(id: unsigned; timeout: unsigned): unaSocksThread;
begin
  result := f_threads.itemById(id, 0, timeout);
  //
  {$IFDEF LOG_UNASOCKETS_ERRORS }
  if (nil = result) then
    logMessage(self._classID + '.getThreadByID() - no thread with id=' + int2str(id));
  {$ENDIF LOG_UNASOCKETS_ERRORS }
end;

// --  --
function unaSocks.getThreadByIndex(index: unsigned): unaSocksThread;
begin
  result := f_threads.get(index);
  //
  {$IFDEF LOG_UNASOCKETS_ERRORS }
  if (nil = result) then
    logMessage(self._classID + '.getThread() - thread index=' + int2str(index) + ' is invalid, or thread does not exists.');
  {$ENDIF LOG_UNASOCKETS_ERRORS }
end;

// --  --
function unaSocks.getThreadFromPool(allowGrowUp: bool): unaSocksThread;
var
  i: int;
begin
  result := nil;
  //
  if (f_threads.lock(4000)) then begin
    try
      for i := 0 to f_threads.count - 1 do begin
	//
	result := getThreadByIndex(i);
	if (nil = result.threadSocket) then
	  break
	else
	  result := nil;
      end;
      //
      if ((nil = result) and allowGrowUp and (f_threads.count < int(c_maxThreadPoolSize))) then begin
	//
	setPoolSize(f_threads.count + f_threads.count shr 1 + 1);
	result := getThreadFromPool(allowGrowUp);
      end
      {$IFDEF DEBUG }
      else
	if (nil = result) then
	  c_maxThreadPoolSize := c_maxThreadPoolSize + 1;
      {$ENDIF DEBUG }	  
      //
    finally
      f_threads.unlock();
    end;
  end;
end;

// --  --
function unaSocks.getThreadSocket(id: unsigned): unaSocket;
var
  thread: unaSocksThread;
begin
  thread := getThreadByID(id);
  if (nil <> thread) then
    result := thread.threadSocket
  else
    result := nil;  
end;

// --  --
function unaSocks.isActive(id: unsigned): bool;
var
  thread: unaSocksThread;
begin
  thread := getThreadById(id);
  //
  if (nil <> thread) then
    result := (unatsRunning = thread.getStatus())
  else
    result := false;
end;

// --  --
procedure unaSocks.leave();
begin
  f_gate.leave();
end;

// --  --
function unaSocks.okToWrite(id, connId, timeout: unsigned; noCheckState: bool): bool;
var
  conn: unaSocksConnection;
begin
  conn := getConnection(id, connId, timeout);
  //
  if (nil <> conn) then begin
    //
    try
      result := conn.okToWrite(timeout, noCheckState);
    finally
      conn.release();
    end;
    //
  end
  else
    result := false;
end;


{$IFDEF VC25_IOCP }

// --  --
procedure unaSocks.recreateThreadsPool();
var
  sz: unsigned;
begin
  // re-createt the pool
  f_threads.clear();
  sz := f_threadPoolSize;
  f_threadPoolSize := 0;
  setPoolSize(sz);
end;

{$ENDIF VC25_IOCP }


// --  --
function unaSocks.removeConnection(id, connId: unsigned): bool;
var
  i: int;
  thread: unaSocksThread;
  okToClose: bool;
begin
  result := false;
  okToClose := false;
  //
  thread := getThreadByID(id);
  if (nil <> thread) then begin
    //
    {$IFDEF VC25_IOCP }
    if (isIOCP) then
      result := unaIOCPSocksThread(thread).removeConnection(connId)
    else
    {$ENDIF VC25_IOCP }
      with (thread) do begin
	//
	i := -1;
	if (connections.lock(10000)) then begin
	  //
	  try
	    i := connections.indexOfId(connId);
	  finally
	    connections.unlock();
	  end;
	end;
	//
	if (0 > i) then begin
	  //
	  {$IFDEF LOG_UNASOCKETS_ERRORS }
	  logMessage(self._classID + '.removeConnection(' + int2str(id) + ', ' + int2str(connId) + ') - no such connection');
	  {$ENDIF LOG_UNASOCKETS_ERRORS }
	end
	else begin
	  //
	  result := connections.removeByIndex(i);
	  //
	  {$IFDEF LOG_UNASOCKETS_INFOS }
	  logMessage(self._classID + '.removeConnection(' + int2str(id) + ', ' + int2str(connId) + ') - connection was removed.');
	  {$ENDIF LOG_UNASOCKETS_INFOS }
	end;
      end;
    //
    okToClose := (not thread.f_isServer and (1 > thread.connections.count));
  end
  else begin
    {$IFDEF LOG_UNASOCKETS_ERRORS }
    logMessage(self._classID + '.removeConnection(' + int2str(id) + ', ' + int2str(connId) + ') - no such thread');
    {$ENDIF LOG_UNASOCKETS_ERRORS }
  end;
  //
  if (okToClose) then
    closeThread(id);
end;

// --  --
function unaSocks.sendData(id: unsigned; data: pointer; size: unsigned; connId: unsigned; out asynch: bool; noCheck: bool; timeout: unsigned): unsigned;
var
  conn: unaSocksConnection;
  {$IFDEF VC25_OVERLAPPED }
  thread: unaSocksThread;
  {$ENDIF VC25_OVERLAPPED }
begin
  result := WSAENOTCONN;	// report some error
  //
  {$IFDEF VC25_OVERLAPPED }
  //
  if (isIOCP) then begin
    //
    thread := getThreadById(id);
    if (nil <> thread) then begin
      //
      {$IFDEF LOG_RAW_DATA_PACKETS }
      logMessage('UNA_SOCKETS: ' + choice(IPPROTO_UDP = f_threadSocket.socketProtocol, 'UDP', 'TCP') + ' ' + choice(f_thread.f_isServer, 'SERVER', 'CLIENT') + ' / about to send new data packet, size=' + int2str(size) + '; CRC32=' + int2str(crc32(data, size), 16));
      {$ENDIF LOG_RAW_DATA_PACKETS }
      //
      // locate connection and send data to it
      result := thread.sendDataTo(connId, data, size, asynch, timeout);
    end;
    //
  end
  else begin
    //
  {$ENDIF VC25_OVERLAPPED }
    //
    {$IFDEF LOG_SOCKS_THREADS }
    infoMessage(className + '.sendData() - about to acquire connId=' + int2str(connId));
    {$ENDIF LOG_SOCKS_THREADS }
    //
    conn := getConnection(id, connId, timeout);
    if (nil <> conn) then begin
      try
	result := conn.send(data, size, noCheck)
      finally
      {$IFDEF LOG_SOCKS_THREADS }
	infoMessage(className + '.sendData() - about to release connId=' + int2str(connId));
      {$ENDIF LOG_SOCKS_THREADS }
	conn.release();
      end;
    end;
    //
  {$IFDEF VC25_OVERLAPPED }
  end;
  {$ENDIF VC25_OVERLAPPED }
end;

{$IFDEF VC25_IOCP }

// --  --
procedure unaSocks.setIsIOCP(value: bool);
begin
  if (not iocpAvailable()) then
    value := false;
  //
  if (value <> isIOCP) then begin
    //
    f_isIOCP := value;
    //
    recreateThreadsPool()
  end;
end;

// --  --
procedure unaSocks.setIsRTP(value: bool);
begin
  if (not iocpAvailable()) then
    value := false;
  //
  if (value <> isRTP) then begin
    //
    f_isRTP := value;
    //
    recreateThreadsPool();
  end;
end;

{$ENDIF VC25_IOCP }

// --  --
procedure unaSocks.setPoolSize(threadsInPool: unsigned);
var
  i: int;
  id: int;
begin
  threadsInPool := max(min(c_maxThreadPoolSize, threadsInPool), 1);
  //
  if (f_threads.lock()) then begin
    try
      if (threadsInPool < f_threadPoolSize) then begin
	// remove unused threads
	i := 0;
	while ((i < int(f_threadPoolSize)) and (i < f_threads.count)) do begin
	  //
	  if (nil = getThreadByIndex(i).threadSocket) then begin
	    //
	    f_threads.removeByIndex(i);
	    dec(i);
	  end;
	  //
	  inc(i);
	end;
	//
      end
      else begin
	// add some threads
	for i := f_threadPoolSize to threadsInPool - 1 do begin
	  //
	  id := InterlockedExchangeAdd(@f_lastThreadID, 1);
	  //
	  {$IFDEF VC25_IOCP }
	  if (isIOCP) then
	    f_threads.add(unaIOCPSocksThread.create(self, id))
	  else
	    f_threads.add(unaSocksThread.create(self, id));
	  {$ELSE }
	  f_threads.add(unaSocksThread.create(self, id));
	  {$ENDIF VC25_IOCP }
	end;
	//
      end;
      //
      f_threadPoolSize := threadsInPool;
    finally
      f_threads.unlock();
    end;
  end;
end;


// -- IP/HTTP --

type

  //
  // -- ipQueryInfo --
  //
  ipQueryInfo = class
  private
    f_queryId: unsigned;
    //
    f_ip: string;
    f_port: string;
    f_query: aString;
    f_proto: int;
    f_callback: tIpQueryCallback;
    f_timeout: unsigned;
    f_isHTTP: bool;
    //
    f_dataPing: int64;
    f_socksId: unsigned;
    f_socksConnId: unsigned;
    f_socksNotSentYet: bool;
    f_socksIsDone: bool;
    //
    f_response: aString;
    f_responseData: aString;
    f_expectedSize: int;
  public
    constructor create(const ip, port, query: string; proto: int; callback: tIpQueryCallback; timeout: unsigned; isHTTP: bool);
    //
    procedure addResponseData(data: paChar; len: unsigned);
    function getDataPingTimeout(): unsigned;
  end;


  //
  // -- ipQueryThread --
  //

  ipQueryThread = class(unaThread)
  private
    f_socks: unaSocks;
    f_queries: unaList;
    f_lastQueryId: int;
    //
    procedure onSocketEvent(sender: tObject; event: unaSocketEvent; id, connId: unsigned; data: pointer; size: unsigned);
    function sendQuery(query: ipQueryInfo): bool;
  protected
    function execute(globalIndex: unsigned): int; override;
  public
    procedure AfterConstruction(); override;
    procedure BeforeDestruction(); override;
    //
    function addQuery(query: ipQueryInfo): int;
  end;


var
  g_ipQueryThread: ipQueryThread;

// --  --
function ensureIpQueryThread(): ipQueryThread;
begin
  if (nil = g_ipQueryThread) then
    g_ipQueryThread := ipQueryThread.create(true, THREAD_PRIORITY_LOWEST);
  //
  result := g_ipQueryThread;
end;


{ ipQueryInfo }

(*

HTTP/1.1 200 OK
Date: Wed, 14 Apr 2004 11:47:05 GMT
Server: Apache/1.3.12 (Win32) PHP/4.0.6
Last-Modified: Sat, 10 Nov 2001 01:07:58 GMT
ETag: "0-39c-3bec7dee"
Accept-Ranges: bytes
Content-Length: 924
Connection: close
Content-Type: text/html

////// DATA GOES HERE //////////////////

*)


// --  --
procedure ipQueryInfo.addResponseData(data: paChar; len: unsigned);
var
  newData: aString;
  posLen: int;
  i: int;
  s: int;
begin
  if ((nil <> data) and (0 < len)) then begin
    //
    f_dataPing := timeMark();
    //
    setLength(newData, len);
    move(data[0], newData[1], len);
    //
    f_response := f_response + newData;
    //
    if (f_isHTTP) then begin
      // check if we got full response
      //
      if (0 > f_expectedSize) then begin
	//
	// try to find the size of response data
	//
	posLen := pos(#13#10'Content-Length:', string(f_response));
	if (1 < posLen) then begin
	  //
	  i := posLen + length(#13#10'Content-Length:');
	  while (i < length(f_response)) do begin
	    //
	    if (('0' <= f_response[i]) and ('9' >= f_response[i])) then
	      break;
	    //
	    inc(i);
	  end;
	  //
	  if ((i < length(f_response)) and ('0' <= f_response[i]) and ('9' >= f_response[i])) then begin
	    //
	    s := i;
	    while (i < length(f_response)) do begin
	      //
	      if (('0' > f_response[i]) or ('9' < f_response[i])) then
		break;
	      //
	      inc(i);
	    end;
	    //
	    if (i < length(f_response)) then
	      f_expectedSize := str2intInt(copy(string(f_response), s, i - s + 1));
	  end;
	  //
	end;
      end;
      //
      posLen := pos(#13#10#13#10, string(f_response));
      if (1 < posLen) then begin
	// extract data we have received so far
	f_responseData := copy(f_response, posLen + 4, choice(0 < f_expectedSize, f_expectedSize, maxInt));
      end;
      //
      f_socksIsDone := ((0 < f_expectedSize) and (length(f_responseData) >= f_expectedSize));
      //
    end	// if (isHTTP) ...
    else
      f_responseData := f_response;
    //
  end;
end;

// --  --
constructor ipQueryInfo.create(const ip, port, query: string; proto: int; callback: tIpQueryCallback; timeout: unsigned; isHTTP: bool);
begin
  f_ip := ip;
  f_port := port;
  f_proto := proto;
  //
  if (isHTTP) then
    f_query := 'GET ' + aString(query) + ' HTTP/1.0'#13#10#13#10
  else
    f_query := aString(query);
  //
  f_callback := callback;
  f_timeout := timeout;
  f_isHTTP := isHTTP;
  //
  f_dataPing := timeMark();
  f_socksIsDone := false;
  f_socksNotSentYet := true;
  f_expectedSize := -1;
  //
  inherited create();
end;

// --  --
function ipQueryInfo.getDataPingTimeout(): unsigned;
begin
  result := timeElapsed32(f_dataPing);
end;


{ ipQueryThread }

// --  --
function ipQueryThread.addQuery(query: ipQueryInfo): int;
begin
  result := -1;
  if ('' <> query.f_query) then begin
    //
    query.f_queryId := InterlockedIncrement(f_lastQueryId);
    query.f_socksId := f_socks.createConnection(query.f_ip, query.f_port, query.f_proto);
    //
    if (0 < query.f_socksId) then begin
      //
      f_queries.add(query);
      result := query.f_queryId;
      //
      wakeUp();
    end;
    //
  end;
end;

// --  --
procedure ipQueryThread.afterConstruction();
begin
  f_socks := unaSocks.create();
  f_queries := unaList.create(uldt_obj);
  f_lastQueryId := 10;
  //
  f_socks.onEvent := onSocketEvent;
  //
  inherited;
end;

// --  --
procedure ipQueryThread.beforeDestruction();
begin
  inherited;
  //
  freeAndNil(f_socks);
  freeAndNil(f_queries);
end;

// --  --
function ipQueryThread.execute(globalIndex: unsigned): int;
var
  i: int;
  query: ipQueryInfo;
begin
  while (not shouldStop) do begin
    //
    sleep(1000);	// 1 sec. sleep could be terminated due to timeout or wakeUp()
    //
    if (not shouldStop) then begin
      //
      // check if we have some job to be done with one or more query
      if (lockNonEmptyList(f_queries)) then try
	//
	i := 0;
	while (i < f_queries.count) do begin
	  //
	  query := f_queries[i];
	  //
	  // should we send our query?
	  if (query.f_socksNotSentYet) then begin
	    // send query's query
	    query.f_socksNotSentYet := not sendQuery(query);
	  end;
	  //
	  // are we done with this query?
	  if (query.f_socksIsDone or (query.f_timeout < query.getDataPingTimeout())) then begin
	    //
	    // notify and remove
	    if (assigned(query.f_callback)) then
	      try
		f_socks.removeConnection(query.f_socksId, query.f_socksConnId);
		//
		query.f_callback(query.f_queryId, string(query.f_query), query.f_response, query.f_responseData);
	      except
	      end;
	    //
	    f_queries.removeByIndex(i);
	  end
	  else
	    inc(i);
	end;
	//
      finally
	unlockList(f_queries);
      end;
      //
    end;
    //
  end;
  //
  result := 0;
end;

// --  --
procedure ipQueryThread.onSocketEvent(sender: tObject; event: unaSocketEvent; id, connId: unsigned; data: pointer; size: unsigned);
var
  i: unsigned;
  query: ipQueryInfo;
begin
  query := nil;
  //
  // locate the query
  if (lockNonEmptyList(f_queries)) then try
    //
    for i := 0 to f_queries.count - 1 do begin
      //
      with (ipQueryInfo(f_queries[i])) do begin
	//
	if (f_socksId = id) then begin
	  //
	  query := f_queries[i];
	  break;
	end;
      end;
    end;
    //
    if (nil <> query) then begin
      //
      case (event) of

	// client
	unaseClientConnect: begin
	  // OK, assign connId
	  query.f_socksConnId := connId;
	end;

	unaseClientData: begin
	  //
	  query.addResponseData(data, size);
	  //
	  if (query.f_socksIsDone) then
	    wakeUp();
	end;

	unaseClientDisconnect: begin
	  //
	  query.f_socksIsDone := true;
	end;

	// thread
	unaseThreadStartupError: begin
	  //
	  query.f_socksIsDone := true;
	end;

      end;	// case
      //
    end;	// if (nil <> query) ...
    //
  finally
    unlockList(f_queries);
  end
end;

// --  --
function ipQueryThread.sendQuery(query: ipQueryInfo): bool;
var
  asynch: bool;
begin
  with (query) do
    result := (0 < f_socks.sendData(f_socksId, @f_query[1], length(f_query), f_socksConnId, asynch, false, f_timeout));
end;


// ------ IP/HTTP procs -------

// --  --
function httpQuery(const ip, port, query: string; callback: tIpQueryCallback; timeout: unsigned): int;
begin
  result := ensureIpQueryThread().addQuery(ipQueryInfo.create(ip, port, query, IPPROTO_TCP, callback, timeout, true));
end;

// --  --
function ipQuery(const ip, port, query: string; proto: int; callback: tIpQueryCallback; timeout: unsigned): int;
begin
  result := ensureIpQueryThread().addQuery(ipQueryInfo.create(ip, port, query, proto, callback, timeout, false));
end;

// --  --
procedure copyURI(w: bool; const u: TURLComponents; var crack: unaURICrack); {$IFDEF UNA_OK_INLINE }inline;{$ENDIF UNA_OK_INLINE }
begin
  {$IFDEF __AFTER_DB__ }
    if (not w) then begin
      //
      // wide chars as ansi chars
      crack.r_scheme 	:= string(lowerCase(copy(paChar(u.lpszScheme), 		1, u.dwSchemeLength)));
      crack.r_hostName 	:= string(lowerCase(copy(paChar(u.lpszHostName), 	1, u.dwHostNameLength)));
      crack.r_userName 	:= string(copy(paChar(u.lpszUserName), 	1, u.dwUserNameLength));
      crack.r_password 	:= string(copy(paChar(u.lpszPassword), 	1, u.dwPasswordLength));
      crack.r_path 	:= string(copy(paChar(u.lpszUrlPath), 	1, u.dwUrlPathLength));
      crack.r_extraInfo	:= string(copy(paChar(u.lpszExtraInfo),	1, u.dwExtraInfoLength));
    end
    else begin
      //
  {$ELSE }
    if (w) then begin
      // ansi chars as wide chars
      crack.r_scheme 	:= lowerCase(copy(pwChar(u.lpszScheme), 	1, u.dwSchemeLength));
      crack.r_hostName 	:= lowerCase(copy(pwChar(u.lpszHostName), 	1, u.dwHostNameLength));
      crack.r_userName 	:= copy(pwChar(u.lpszUserName),  1, u.dwUserNameLength);
      crack.r_password 	:= copy(pwChar(u.lpszPassword),  1, u.dwPasswordLength);
      crack.r_path 	:= copy(pwChar(u.lpszUrlPath), 	 1, u.dwUrlPathLength);
      crack.r_extraInfo	:= copy(pwChar(u.lpszExtraInfo), 1, u.dwExtraInfoLength);
    end
    else begin
      //
  {$ENDIF __AFTER_DB__ }
      // ansi chars as ansi chars OR wide chars as wide chars
      crack.r_scheme 	:= lowerCase(copy(u.lpszScheme, 	1, u.dwSchemeLength));
      crack.r_hostName 	:= lowerCase(copy(u.lpszHostName, 	1, u.dwHostNameLength));
      crack.r_userName 	:= copy(u.lpszUserName,	 1, u.dwUserNameLength);
      crack.r_password 	:= copy(u.lpszPassword,  1, u.dwPasswordLength);
      crack.r_path 	:= copy(u.lpszUrlPath, 	 1, u.dwUrlPathLength);
      crack.r_extraInfo := copy(u.lpszExtraInfo, 1, u.dwExtraInfoLength);
    end;
end;

// --  --
function crackURI(const URI: string; var crack: unaURICrack; flags: DWORD): bool;
var
  uriComponents: TURLComponents;	// either ANSI or Wide pChars, depending on compiler version
begin
  fillChar(uriComponents, sizeof(TURLComponents), #0);
  uriComponents.dwStructSize := sizeOf(uriComponents);
  uriComponents.dwSchemeLength := 1;
  uriComponents.dwHostNameLength := 1;
  uriComponents.dwUserNameLength := 1;
  uriComponents.dwPasswordLength := 1;
  uriComponents.dwUrlPathLength := 1;
  uriComponents.dwExtraInfoLength := 1;
  //
{$IFNDEF NO_ANSI_SUPPORT }
  if (g_wideApiSupported) then begin
{$ENDIF NO_ANSI_SUPPORT }
    result := InternetCrackUrlW(pwChar(wString(URI)), 0, flags, uriComponents);
{$IFNDEF NO_ANSI_SUPPORT }
  end
  else
    result := InternetCrackUrlA(paChar(aString(URI)), 0, flags, uriComponents);
{$ENDIF NO_ANSI_SUPPORT }
  //
  if (result) then begin
    //
    crack.r_port := uriComponents.nPort;
    //
    {$IFNDEF NO_ANSI_SUPPORT }
      if (g_wideApiSupported) then begin
    {$ENDIF NO_ANSI_SUPPORT }
	copyURI(true, uriComponents, crack);
    {$IFNDEF NO_ANSI_SUPPORT }
      end
      else
	copyURI(false, uriComponents, crack);
    {$ENDIF NO_ANSI_SUPPORT }
  end;
end;


// -- unit globals --

initialization
  g_unaWSAGate := unaInProcessGate.create();
  g_unaWSAGateReady := true;

{$IFDEF LOG_UNASOCKETS_INFOS }
  logMessage('unaSockets - DEBUG is defined.');
{$ENDIF LOG_UNASOCKETS_INFOS }

  //
  startup();


finalization
{$IFDEF LOG_UNASOCKETS_INFOS }
  logMessage('unaSockets - finalizing.');
{$ENDIF LOG_UNASOCKETS_INFOS }
  //
  freeAndNil(g_ipQueryThread);

  //
  shutdown();

  //
  g_unaWSAGateReady := false;
  //
  if (g_unaWSAGate.enter(3000)) then	// make sure no one is using the gate
    g_unaWSAGate.leave();

  // g_unaWSAGateReady will not allow gate to be used
  freeAndNil(g_unaWSAGate);
end.


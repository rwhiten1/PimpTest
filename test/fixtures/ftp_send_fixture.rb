require 'ie_ftp'

#This is a fixture dedicated to sending data into IEFE via FTP.
#it will handle sending plain text, binary, and all 4 edi types.
#Author:: Rob Whitener
class FtpSendFixture

  attr_accessor :sender,:receiver,:address,:msgclass,:keepalive,:filename

  def initialize()
    @sender = ""
    @receiver = ""
    @address =""
    @msgclass =""
    @keepalive = false
    @filename = ""
    @ftp_client = nil
  end

  #This method sends plain text data from the sender to the receiver
  #It expects a message class to be explicitly handed to it.  Also,
  #if keepalive is true, it will keep the FTP session alive across method calls
  #params:: @address @sender @receiver @msgclass @filename @keepalive
  #type:: table
  #format:
  # |sender|receiver|msgclass|address|filename|keepalive|send_text_data()|
  # |aSender|aRecvr|SOMECLS|10.160.9.51|/some/file/data|true|OK|
  def send_text_data()
    @ftp_client = new IeFtp(@address) if !@ftp_client.connected?
    @ftp_client.send_text_file(@filename,@sender,@receiver,@msgclass)
    @ftp_client.ie_disconnect if !@keepalive
  end

  #This method sends EDI data from the sender to the receiver
  #The message class and table name are passed in normally, but will
  #be added to the siteparams if needed.  Any other site params that
  #need to be applied to the session should be put into the siteparms field in the
  #style of: parm=>val;parm=>val.  Also,
  #if keepalive is true, it will keep the FTP session alive across method calls
  #params:: @address @sender @senderedi @senderqual @receiveredi @rcvrqual @type @msgclass @siteparm @filename
  #type:: table
  #format:
  # |sender|senderedi|senderqual|receiveredi|receiverqual|msgclass|address|filename|type|siteparm|send_edi_data()|
  # |aSender|sndedi|sndqual|recvedi|recvqual|SOMECLS|10.160.9.51|/some/file/data|x|edialiasonly=>on|OK|
  def send_edi_data()
    @ftp_client = new IeFtp(@address) if !@ftp_client.connected?
    @ftp_client.send_text_file(@filename,@sender,@receiver,@msgclass)
    @ftp_client.ie_disconnect if !@keepalive
  end
end

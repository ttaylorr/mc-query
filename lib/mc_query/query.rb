require 'net/http'

module MCQuery
  class Query
    @@MAGIC = "\xFE\xFD"
    @@REQUEST = "#{@@MAGIC}\x00"
    @@HANDSHAKE = "#{@@MAGIC}\x09"

    def initialize(opts = {})
      # Merge in the default options
      opts = {:ip => 'localhost', :port => '25565', :timeout => 8}.merge(opts)

      @ip = opts[:ip]
      @port = opts[:port]
      @timeout = opts[:timeout]

      # Connect to the server socket (based on the options)
      @socket = UDPSocket.new
      @socket.connect(@ip, @port)

      # Generate a session id and store it off
      @session_id = get_session_id
    end

    # Public: Do the Minecraft dance (according to the protocol) and
    #         send back a hash of the result
    #
    # Examples
    #
    #   simple_query
    #   # => {
    #          :name => "My Server",
    #          :gametype => "SMP",
    #          :world_name => "world",
    #          :online_players => "0",
    #          :max_players => "150",
    #          :ip => "10.0.0.1",
    #        }
    #
    # Returns the named hash of the data contained in the simple query
    def simple_query
      # Store off the challenge key (we'll need this for querying)
      @challenge = get_challenge_key

      timeout @timeout do
        query = @socket.send(encode_data("#{@@REQUEST}#{@session_id}") + @challenge.to_s, 0)
        buffer = recieve_data
        parsed = buffer.split("\0", 6)

        {
          :name => parsed[0],
          :gametype => parsed[1],
          :world_name => parsed[2],
          :online_players => parsed[3],
          :max_players => parsed[4],
          :ip => parsed[5]
        }
      end
    end

    def get_challenge_key
      timeout @timeout do
        # Send the magic bytes, the handshake bytes, and the session id
        send_data("#{@@HANDSHAKE}#{@session_id}")

        # Get the raw data (splice out the headers, and convert to an int32)
        raw_key = recieve_data.to_i

        # Pack it as big endian and return it
        [raw_key].pack("N") 
      end
    end

    private
    def get_session_id
      [(rand(32) + 1) & 0x0F0F0F0F].pack("N")
    end

    def send_data(data)
      @socket.send(encode_data(data), 0)
    end

    def encode_data(data)
      data.force_encoding(Encoding::ASCII_8BIT)
    end

    def recieve_data
      # Recieve the data, splicing out the headers
      @socket.recvfrom(1460)[0][5...-1]
    end
  end
end

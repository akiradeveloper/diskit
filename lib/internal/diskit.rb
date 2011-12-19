require "pathname"

RAMFS="/dev/shm"

class Disk
  def initialize(name)
    @uuid = UUID.of(name)
    @name = name
  end

  def self.by_name(name)
  end

  def self.by_uuid(uuid)
  end

  def read(range)
  end

  def write(range, buffer)
  end
end

class Buffer

  def initialize(bytes)
    @id = object_id
    @bytes = bytes
    @f = nil
  end

  def open
    @f = File.open(filename(), "wb")
    @f.write(pack)
  end

  def close
    @f.close
  end

  def filename
    RAMFS + "/" + @id.to_s
  end

  def pack
    ns = @bytes.map { |x| x.to_i }
    ns.pack("c#{ns.size}")
  end

  def fit?(range)
  end

  def cut(range)
  end

  def ==(another)
  end
end

class Byte

  def initialize(num)
    @num = num
  end

  def to_i
    @num
  end

  # 'x'
  def self.by_c(c)
    Byte.new c.unpack('C')[0]
  end

  # 0b11110000
  def self.by_b(b)
    Byte.new b
  end

  FILL  = Byte.by_b(0b11111111)
  EMPTY = Byte.by_b(0b00000000)
end

module UUID

  def self.of(name)
    relname = Pathname.new(name).relative_path_from(Pathname.new("/dev/disk/by-uuid")).to_s
    m = self.mk_table
    m.each { |k, v|
      if k == relname
        return v
      end  
    }
    raise ArgumentError, "UUID for the diskname not found"
  end

  # ../../sda1 means the relative path from /dev/disk/by-uuid
  def self.mk_table
    m = {}
    r = `ls -l /dev/disk/by-uuid`
    rr = r.split("\n")
    rr.delete_at(0)
    rr.each { |line|
      _line = line.split(" ")
      uuid, name = _line[7], _line[9]
      m[name] = uuid
    }
    return m
  end

  class Table
    def initialize
      @map = {}
    end
    def filename
      "~/.diskit"
    end
    def save
    end
    def init
    end
    def lookup(name)
    end
    def valid?(name)
      cur_uuid = UUID.of(name)
      lookup(name) == cur_uuid
    end
    def ensure
    end
  end
end

if __FILE__ == $0
  p UUID.of("/dev/sda1")
  p UUID.mk_table
  b1 = Byte.by_c('a')
  p b1
  b2 = Byte.by_b(0b11110000)
  p b2
  buf = Buffer.new([b1, b2])
  p buf
  buf.open
  p buf
end

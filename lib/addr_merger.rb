# from https://github.com/noahhaon/cidr-lite-ruby

class AddrMerger

  def initialize( options = {} )
    @nbits = 40
    @masks = (0..@nbits).map{ |i| ("1" * i) + ("0" * (40-i)) }.map{ |m| [m].pack("B*") }
    @ranges = Hash.new(0)
  end

  def add(cidr)
    (ip, mask) = cidr.split('/')
    mask ||= "32"
    mask = mask.to_i
    raise "Bad mask" if mask == 0 or mask > 32
    mask += 8
    cidr_start = pack_ipv4(ip).unpack('B*').first.to_i(2) & @masks[mask].unpack('B*').first.to_i(2)
    cidr_start = ["%040B" % cidr_start].pack("B*")
    cidr_end   = add_bit(cidr_start, mask)

    @ranges[cidr_start] += 1 || @ranges.delete(cidr_end)
    @ranges[cidr_end]   -= 1 || @ranges.delete(cidr_end)
  end

  def list
    results = []
    start = total = 0
    @ranges.keys.sort.each do |ip|
      start = ip if total == 0
      total += @ranges[ip]

      if total == 0
        while start < ip
          bits = p_end = nil
          start_bits = start.unpack('b*').first
          sbit = @nbits - 1

          sbit -= 1 while (start_bits[sbit^7] == "0" and sbit > 0)

          ((sbit+1)..@nbits).each do |pos|
            p_end = add_bit(start, pos)
            if p_end <= ip
              bits = pos - 8
              break
            end
          end

          results << unpack_ipv4(start) + "/#{bits}"
          start = p_end
        end
      end
    end

    results
  end

  private

  def pack_ipv4(ip)
    nums = ip.split('.').map(&:to_i)
    return unless nums.length == 4
    return unless nums.all?{ |n| n >= 0 and n.to_i <= 255 }
    nums.unshift(0).pack('C*')
  end

  def unpack_ipv4(ip)
    ip.unpack('xC*').join('.')
  end

  def add_bit(addr, mask_bits)
    mask_bits -= 1
    addr_bits = addr.unpack('b*').first

    while addr_bits[mask_bits^7] == "1" do
      addr_bits[mask_bits^7] = "0"
      mask_bits -= 1
    end
    addr_bits[mask_bits ^ 7] = "1"
    [addr_bits].pack('b*')
  end
end

class String
    def indent(spaces)
      indent = " " * spaces
      self.gsub(/^(?=.)/, indent)
    end
end


def bit_ranges(mask)
    ranges = []
    lsb = 0
    while mask != 0
        while (mask & 1) == 0
            lsb += 1
            mask >>= 1
        end
        msb = lsb - 1
        while (mask & 1) == 1
            msb += 1
            mask >>= 1
        end
        ranges << [msb, lsb]
        lsb = msb + 1
    end
    return ranges
end


def format_binary(n, width)
    "#{"%0#{width}b" % n}"
end

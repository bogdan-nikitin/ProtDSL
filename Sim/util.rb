class String
    def indent(spaces)
      indent = " " * spaces
      self.gsub(/^(?=.)/, indent)
    end
end



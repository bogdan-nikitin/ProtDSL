require_relative "base"

module SimInfra
    IrStmt = Struct.new(:name, :oprnds, :attrs)
    class Var
        attr_reader :scope, :name, :type
        def initialize(scope, name, type)
            @scope = scope; @name = name; @type = type;
        end
        # Syntax "var[]=value" is used to assign variable
        # it's similar to "var[hi:lo]=value" for partial assignment
        def []=(other)
            @scope.stmt(:let, [self, other])
            if @scope.regs.include? self.name
                @scope.stmt(:setreg, [@scope.regs[self.name], self])
            end
        end

        # dumps states and disables @scope dump
        def inspect; "Var #{@name}:#{@type} (#{@scope.object_id})"; end
    end
end

module SimInfra
    # constant resolution (type check, initialization of constant type/value)
    class Constant
        attr_reader :scope, :name, :type, :const
        def initialize(scope, name, value);
            @scope = scope
            @name = name
            @const = value
            @type = :iconst
            @scope.stmt(:new_const, [self, @const])
        end
        def let(other); raise "Assign to constant"; end
        def inspect
            "Const #{@name}:#{@type} (#{@scope.object_id}) {=#{@const}}"
        end
    end
    #
    class Var
        def+(other); @scope.add(self, other); end
        def-(other); @scope.sub(self, other); end
        def<<(other); @scope.shl(self, other); end
        def>>(other); @scope.lshr(self, other); end
        def^(other); @scope.xor(self, other); end
        def==(other); @scope.eq(self, other); end
        def!=(other); @scope.ne(self, other); end
        def&(other); @scope.and(self, other); end
        def|(other); @scope.or(self, other); end
        def<(other); @scope.ult(self, other); end
        def>=(other); @scope.uge(self, other); end
        def*(other); @scope.mul(self, other); end
        def/(other); @scope.div(self, other); end
        def%(other); @scope.mod(self, other); end
    end
end

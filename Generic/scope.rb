require_relative "base"
require_relative "var"

module SimInfra
    class Scope

        include GlobalCounter# used for temp variables IDs
        attr_reader :tree, :vars, :parent, :regs
        def initialize(parent); @tree = []; @vars = {}; @regs = {} end
        # resolve allows to convert Ruby Integer constants to Constant instance

        def var(name, type)
            @vars[name] = SimInfra::Var.new(self, name, type) # return var
            instance_eval "def #{name.to_s}(); return @vars[:#{name.to_s}]; end"
            stmt :new_var, [@vars[name]] # returns @vars[name]
        end

        def reg(operand)
            @regs[operand.name] = operand
        end

        def add_var(name, type); var(name, type); self; end
        def add_reg(operand); reg(operand); self; end

        def resolve_arg(what)
            if (what.class == Var) and @regs.include? what.name 
                stmt(:getreg, [what, @regs[what.name]])
            end
            return what if (what.class== Var) or (what.class== Constant) # or other known classes
            return Constant.new(self, "const_#{next_counter}", what) if (what.class== Integer)
        end

        def binOp(a, b, op);
            a = resolve_arg(a)
            b = resolve_arg(b)
            # TODO: check constant size <= bitsize(var)
            # assert(a.type== b.type|| a.type == :iconst || b.type== :iconst)

            stmt op, [tmpvar(a.type), a, b]
        end

        # redefine! add & sub will never be the same
        def add(a, b); binOp(a, b, :add); end
        def sub(a, b); binOp(a, b, :sub); end
        def shl(a, b); binOp(a, b, :shl); end
        def xor(a, b); binOp(a, b, :xor); end
        # def zext(a, b); binOp(a, b, :zext); end

        private def tmpvar(type); var("_tmp#{next_counter}".to_sym, type); end
        # stmtadds statement into tree and retursoperand[0]
        # which result in near all cases
        def stmt(name, operands, attrs= nil);
            @tree << IrStmt.new(name, operands, attrs); operands[0]
        end
    end
end

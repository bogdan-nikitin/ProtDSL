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
                stmt :getreg, [what, @regs[what.name]]
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

        def unOp(a, op);
            a = resolve_arg(a)
            stmt op, [tmpvar(a.type), a]
        end

        def add(a, b); binOp(a, b, :add); end
        def sub(a, b); binOp(a, b, :sub); end
        def shl(a, b); binOp(a, b, :shl); end
        def xor(a, b); binOp(a, b, :xor); end
        def eq(a, b); binOp(a, b, :eq); end
        def ne(a, b); binOp(a, b, :ne); end
        def and(a, b); binOp(a, b, :and); end
        def or(a, b); binOp(a, b, :or); end
        def ult(a, b); binOp(a, b, :ult); end
        def uge(a, b); binOp(a, b, :uge); end
        def ashr(a, b); binOp(a, b, :ashr); end
        def lshr(a, b); binOp(a, b, :lshr); end
        def mul(a, b); binOp(a, b, :mul); end
        def div(a, b); binOp(a, b, :div); end
        def mod(a, b); binOp(a, b, :mod); end
        def select(cond, a, b)
            cond = resolve_arg(cond)
            a = resolve_arg(a)
            b = resolve_arg(b)
            stmt :select, [tmpvar(a.type), cond, a, b]
        end
        # def zext(a, b); binOp(a, b, :zext); end
        
        # memory
        def load8(a);  unOp(a, :load8); end
        def load16(a); unOp(a, :load16); end
        def load32(a); unOp(a, :load32); end

        def store8(a, b);  binOp(a, b, :store8); end
        def store16(a, b); binOp(a, b, :store16); end
        def store32(a, b); binOp(a, b, :store32); end

        private def tmpvar(type); var("_tmp#{next_counter}".to_sym, type); end
        # stmtadds statement into tree and retursoperand[0]
        # which result in near all cases
        def stmt(name, operands, attrs= nil);
            @tree << IrStmt.new(name, operands, attrs); operands[0]
        end
    end
end

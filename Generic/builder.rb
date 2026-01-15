require_relative "scope"

# Basics
module SimInfra
    def assert(condition, msg = nil); raise msg if !condition; end

    @@instructions = []
    InstructionInfo = Struct.new(:name, :fields, :format, :code, :args, :asm)
    class InstructionInfoBuilder
        def initialize(name, *args);
            @info = InstructionInfo.new(name)
            @info.args = args
            @info.asm = nil
            # Make args available as methods in the builder context
            args.each do |arg|
                define_singleton_method(arg.name) { arg }
            end
        end
        def encoding(format, fields)
            @info.fields = fields
            @info.format = format 
        end

        def asm(&block)
            @info.asm = instance_eval(&block)
        end

        attr_reader :info
    end

    def Instruction(name, *args, &block)
        bldr = InstructionInfoBuilder.new(name, *args)
        bldr.instance_eval &block
        @@instructions << bldr.info
        nil # only for debugging in IRB
    end

    class Operand
        attr_reader :name, :kind, :attrs
        def initialize(name, kind, attrs)
            @name = name
            @kind = kind
            @attrs = attrs
        end

        def inspect
            "Operand #{@name}:#{@kind} #{@attrs} (#{@scope.object_id})"
        end
    end

    Register = Struct.new(:name, :size, :attrs)

    @@register_files = []
    RegisterFileInfo = Struct.new(:name, :size, :registers)
    class RegisterFileInfoBuilder
        def initialize(name, size)
            @info = RegisterFileInfo.new(name)
            @info.size = size
            @info.registers = []
        end

        def reg(name, *attrs)
            @info.registers << Register.new(name, @info.size, attrs)
        end

        attr_reader :info
    end

    def RegisterFile(name, size, &block)
        bldr = RegisterFileInfoBuilder.new(name, size)
        bldr.instance_eval &block
        @@register_files << bldr.info
        nil # only for debugging in IRB
    end
end

# * generate precise fields
module SimInfra
    class InstructionInfoBuilder
    include SimInfra
        def code(&block)
            @info.code = scope = Scope.new(nil) # root scope
            @info.args.each do |arg|
                scope.add_var(arg.name, :i32)
                if arg.kind == :regclass
                    scope.add_reg(arg)
                elsif arg.kind == :operand
                    scope.stmt(:init_imm, [scope.vars[arg.name], arg])
                end
            end

            scope.instance_eval &block
        end
    end
end

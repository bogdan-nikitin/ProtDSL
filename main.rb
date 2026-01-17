#!/usr/bin/ruby
require_relative "Generic/base"
require_relative "Generic/builder"
require_relative "Target/RISC-V/32I.rb"

require_relative "Sim/cpu_state"
require_relative "Sim/executor"
require_relative "Sim/opcode"
require_relative "Sim/decoder"

# SimInfra.dump
SimInfra.serialize

File.write('gen/cpu_state.h', SimInfra.gen_cpu_state)
File.write('gen/executor.h', SimInfra.gen_executor)
File.write('gen/opcode.h', SimInfra.gen_opcode)
File.write('gen/decoder.h', SimInfra.gen_decoder)

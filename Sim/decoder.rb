require_relative 'util'


module SimInfra
    module Decoder
        DecoderTreeNode = Struct.new(:msb, :lsb, :nodes)

        def self.defined_bits(insn)
            mask = 0
            bits = 0
            for field in insn.fields
                value = field.value
                next if value.class != Integer
                msb, lsb = field.from, field.to
                width = msb - lsb + 1
                mask |= ((1 << width) - 1) << lsb
                bits |= value << lsb
            end
            return bits, mask
        end

        def self.get_lead_bits(instructions, separ_mask = 0)
            all_mask = (1 << 32) - 1

            for insn in instructions
                _, mask = defined_bits(insn)
                mask ^= mask & separ_mask
                _ &= mask
                all_mask &= mask
            end

            ranges = bit_ranges(all_mask)
            lead_bits = {}
            for rng in ranges
                msb, lsb = rng
                values = Set[]
                width = msb - lsb + 1
                range_mask = ((1 << width) - 1) << lsb

                for insn in instructions
                    bits, mask = defined_bits(insn)
                    mask &= range_mask
                    mask ^= mask & separ_mask
                    bits &= mask
                    values << bits
                end
                lead_bits[rng] = values.size
            end
            lead_bits
        end

        def self.get_maj_range(lead_bits) 
            max_value = 0
            maj = nil
            for rng, value in lead_bits
                if value > max_value
                    max_value = value
                    maj = rng
                end
            end
            maj
        end

        def self.filter_instructions(instructions, node, separ_mask)
            instructions.select { |insn| 
                bits, mask = defined_bits(insn)
                if mask & separ_mask != separ_mask
                    raise 'filter on unknown bits'
                end
                bits & separ_mask == node
            }
        end

        def self.init_children(sublist, node = 0, separ_mask = 0)
            lead_bits = get_lead_bits(sublist, separ_mask)
            msb, lsb = get_maj_range(lead_bits)
            print sublist.map { |insn| insn.name }, "\n"
            width = msb - lsb + 1
            tree = DecoderTreeNode.new(msb, lsb, {})
            new_mask = separ_mask | ((1 << width) - 1 << lsb)
            for node_value in 0..((1 << width) - 1)
                actual_node = node | (node_value << lsb)
                subtree, is_leaf, result = make_child(actual_node, new_mask, sublist)
                if is_leaf == true
                    tree.nodes[node_value] = result
                elsif subtree != nil and !subtree.nodes.empty?
                    tree.nodes[node_value] = subtree
                end
            end
            tree
        end

        def self.make_head(instructions)
            init_children(instructions)
        end

        # returns tree, ok, sublist
        def self.make_child(node, separ_mask, instructions)
            sublist = filter_instructions(instructions, node, separ_mask)
            if sublist.empty?
                return nil, nil, nil
            end
            if sublist.length == 1
                return nil, true, sublist[0]
            end

            tree = init_children(sublist, node, separ_mask)
            return tree, nil, nil
        end
    end

    # for debug
    def self.pp_tree(tree, indent = 0) 
        return if tree == nil
        left = " " * indent
        if tree.class == Decoder::DecoderTreeNode
            printf "%smsb: %s, lsb: %s\n" % [left, tree.msb, tree.lsb]
            for val, node in tree.nodes
                printf "%s%b\n" % [left, val << tree.lsb]
                pp_tree(node, indent + 2)
            end
        else
            printf "%s%s\n" % [left, tree.name]
        end
    end

    def self.gen_leaf(insn)
        lines = ["decoded.opcode = Opcode::#{insn.name};"]
        insn.args.each_with_index do |opd, i| 
            field = insn.fields.find do |field| field.name == opd.name end
            lines << "decoded.operands[#{i}] = slice(insn, #{field.from}, #{field.to});"
        end
        lines << "return decoded;"
        lines.join "\n"
    end

    def self.gen_decoder_node(node)
        if node.class != Decoder::DecoderTreeNode
            return gen_leaf(node)
        end
        width = node.msb - node.lsb + 1
        cases = []
        for value, subtree in node.nodes
            cases << <<DEF
case 0b#{format_binary(value, width)}:
#{gen_decoder_node(subtree).indent(4)}
#{
<<BREAK if subtree.class == Decoder::DecoderTreeNode
    break;
BREAK
}
DEF
        end
<<DEF
switch ((insn >> #{node.lsb}) & 0b#{format_binary((1 << width) - 1, width)}) {
#{cases.join ""}
}
DEF
    end

    def self.gen_decoder
        tree = Decoder::make_head(@@instructions)
<<CPP
#pragma once
#include <stdexcept>
#include "instruction.h"
#include "util.h"


struct DecodeError : public std::runtime_error {
     using std::runtime_error::runtime_error;
};


struct Decoder {
    Instruction decode(uint32_t insn) {
        Instruction decoded;
#{gen_decoder_node(tree).indent(8)}
        throw DecodeError{"invalid instruction"};
    }
};
CPP
    end
end

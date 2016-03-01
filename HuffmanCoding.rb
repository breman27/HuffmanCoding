#Brett Long
#2/11/2016

require 'test/unit'

class Node
  def initialize(char=nil, value)
    @char = char
    @value = value
    @left = nil
    @right = nil
  end
  
  def walk(&block)
    walk_node('', &block)
  end
  
  #Simple preorder traversal
  def walk_node(code, &block)
    yield(self, code)
    @left.walk_node(code + '0', &block) unless not @left
    @right.walk_node(code + '1', &block) unless not @right
  end

  attr_accessor :char, :value, :left, :right
end

class Huffman

=begin
Must create an internal Huffman tree for the given text and from this an
encoding table. No Huffman tree and an empty encoding table must be created for a text of
less than two characters
=end
  def initialize(text)
    if text.length > 1
      @text = text
      @root = create_hufftree(text)
      @table = create_table(@text)
    else
      @text = text
      @table = ""
    end
  end

=begin
Creates the table to be used in encoding.
=end
  def create_table(text)
    h = countChars(text)
    codes = Hash.new
    #Walk through each node and increment the code, if we find the leaf, we assign the code to the character
    #at that leaf.
    @root.walk { |node, code| codes[node.char] = code if node.char != nil }
    return codes
  end
  
=begin
This function actually creates the huffman tree and returns the root node
when finished.
=end
  def create_hufftree(text)
    # First we need a count of all the characters
    arr = Array.new
    h = countChars(text)
    h.each{|k, v| arr.push(Node.new(k, v))}
    while(arr.length > 1)
      # Sorted in reverse so we can easily pop the two smallest values
      arr = arr.sort_by{|k| k.value}.reverse
      a = arr.pop()
      b = arr.pop()
      
      node = Node.new(nil, a.value + b.value)
      node.left = a
      node.right = b
      
      arr.push(node)
    end
    return arr.pop()
  end
  
=begin
Helper method pulled from PA6
=end
  def countChars(str)
    h = Hash.new
    str.split("").each {|c| h[c] = str.count(c) if not h.has_key?(c)}
    return h
  end
  
=begin
Must encode the given text (or the text provided as the constructor
argument if no argument is given) into a bit string using the class’s coding table and return it.
Note that if a text is provided as a parameter, it may contain characters missing from the
class’s coding table. Any such characters must be ignored in the encoding process; that is, they
are treated as if they did not exist
=end
  def encode(text=nil)
    if(text == nil)
      text = @text
    end
    ret = ""
    text.split("").each {|c| ret += @table[c] if @table.has_key?(c)}
    return ret
  end
  
=begin
Must decode the bit_string using the class’s Huffman encoding tree. Note
that any bit string can be decoded using a Huffman tree, but it may have some extra bits on
the end. Any terminal bits that do not translate to a character (that is, they do not defne a
path from the root all the way to a leaf ) must be ignored
=end
  def decode(bit_string)
    node = @root
    ret = ''
    bit_string.split("").each do |c|
      if c == '1'
        node = node.right
      elsif c == '0'
        node = node.left
      else
        puts 'Error, not a bitstring'
        break
      end
      
      if node == nil
        next
      elsif node.char != nil
        ret += node.char
        node = @root
      end
    end
    return ret
  end
  
  attr_reader :text, :table, :root
  private :countChars
end


class Huffman_Test<Test::Unit::TestCase
  def testInit()
    huff = Huffman.new("aaaabbccccccccccddd")
    assert_equal(nil, huff.root.char)
    assert_equal(19, huff.root.value)
    assert_equal('b', huff.root.left.right.left.char)
    assert_equal(10, huff.root.right.value)
  end
  
  def testDecode()
    huff2 = Huffman.new("abbccccasdkfhqowiegasdkbaiesoasiaaaaaaaaaaaajd")
    huff3 = Huffman.new("Mississippi State")
    assert_equal("ississiiae", huff2.decode(huff2.encode("Mississippi State")))
    assert_equal("aasieasaiesasiaaaaaaaaaaaa", huff3.decode(huff3.encode("abbccccasdkfhqowiegasdkbaiesoasiaaaaaaaaaaaajd")))
    assert_equal("Mississippi State", huff3.decode(huff3.encode("Mississippi State")))
    assert_equal("abbccccasdkfhqowiegasdkbaiesoasiaaaaaaaaaaaajd", huff2.decode(huff2.encode("abbccccasdkfhqowiegasdkbaiesoasiaaaaaaaaaaaajd")))
  end
end
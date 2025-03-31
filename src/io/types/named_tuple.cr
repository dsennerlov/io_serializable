require "../../io_serializable"

struct NamedTuple
  def to_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : Nil
    {% for key in T.keys %}
      {% actual_type = T[key].union_types.reject { |t| t == Nil }.first %}

      {% if T[key].nilable? %}
        IoSerializable::Writer.write_nil_flag(io, self[{{key.symbolize}}].nil?, format)
      {% end %}

      unless self[{{key.symbolize}}].nil?
        {% if actual_type.has_method?(:to_io) %}
          self[{{key.symbolize}}].not_nil!.to_io(io, format)
        {% elsif Integer::Primitive.includes?(actual_type) %}
          IoSerializable::Writer.write_int(io, self[{{key.symbolize}}], format)
        {% elsif Float::Primitive.includes?(actual_type) %}
          IoSerializable::Writer.write_float(io, self[{{key.symbolize}}], format)
        {% end %}
      end
    {% end %}
  end

  def self.from_io(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian) : self
    {% begin %}
      return NamedTuple.new(
        {% for key, type in T %}
          {% actual_type = type.union_types.reject { |t| t == Nil }.first %}

          {{key}}: {% if type.nilable? %}
            (1 == IoSerializable::Reader.read_nil_flag(io, format)) ? nil :
          {% end %}
          {% if actual_type.class.has_method?(:from_io) %}
            {{actual_type}}.from_io(io, format),
          {% elsif Integer::Primitive.includes?(actual_type) %}
            IoSerializable::Reader.read_int(io, {{actual_type}}, format),
          {% elsif Float::Primitive.includes?(actual_type) %}
            IoSerializable::Reader.read_float(io, {{actual_type}}, format),
          {% end %}
        {% end %}
      )
    {% end %}
  end
end

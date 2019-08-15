module Xgb
  class DMatrix
    attr_reader :data, :label, :weight

    def initialize(data, label: nil, weight: nil, missing: Float::NAN)
      @data = data
      @label = label
      @weight = weight

      @handle = ::FFI::MemoryPointer.new(:pointer)

      if data
        c_data = ::FFI::MemoryPointer.new(:float, data.count * data.first.count)
        c_data.put_array_of_float(0, data.flatten)
        check_result FFI.XGDMatrixCreateFromMat(c_data, data.count, data.first.count, missing, @handle)
      end

      set_float_info("label", label) if label
    end

    def num_row
      out = ::FFI::MemoryPointer.new(:ulong)
      check_result FFI.XGDMatrixNumRow(handle_pointer, out)
      out.read_ulong
    end

    def num_col
      out = ::FFI::MemoryPointer.new(:ulong)
      check_result FFI.XGDMatrixNumCol(handle_pointer, out)
      out.read_ulong
    end

    def slice(rindex)
      res = DMatrix.new(nil)
      idxset = ::FFI::MemoryPointer.new(:int, rindex.count)
      idxset.put_array_of_int(0, rindex)
      check_result FFI.XGDMatrixSliceDMatrix(handle_pointer, idxset, rindex.size, res.handle)
      res
    end

    def save_binary(fname, silent: true)
      check_result FFI.XGDMatrixSaveBinary(handle_pointer, fname, silent ? 1 : 0)
    end

    def handle
      @handle
    end

    def handle_pointer
      @handle.read_pointer
    end

    private

    def set_float_info(field, data)
      c_data = ::FFI::MemoryPointer.new(:float, data.count)
      c_data.put_array_of_float(0, data)
      check_result FFI.XGDMatrixSetFloatInfo(handle_pointer, field.to_s, c_data, data.size)
    end

    include Utils
  end
end

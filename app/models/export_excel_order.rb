require 'spreadsheet'

class ExportExcelOrder
  def initialize(orders)
    @orders = orders
    Spreadsheet.client_encoding = 'UTF-8'
    @book = Spreadsheet::Workbook.new
  end

  def save_to_file(file_name)
    @orders.each do |order|
      create_order_worksheet(order)
    end
    write_to_file(file_name)
  end

  def create_order_worksheet(order)
    #create a sheet with site name
    working_sheet = @book.create_worksheet name: order.site.name
    
    #write table header with [cell_data, cell_width]
    head_labels = [ ["Commodity", 30], ["Pack Size", 15], ["Strength", 15], ["Unit", 10] , ["#Patient", 15], 
                    ["Stock on hand", 20], ["Monthly Use", 20], ["System Suggestion", 30],
                    ["Quantity Suggested", 30], ["Status", 15], ["Data Entry Note", 30], ["Reviewer note", 30] ]

    format_header = Spreadsheet::Format.new color: :black, weight: :bold, size: 16, border: :thin,
                                            pattern_fg_color: :silver, pattern: 1 
    # working_sheet.row(0).default_format = format_header

    head_labels.each_with_index do |head_label, i|
      working_sheet[0,i] = head_label[0]
      working_sheet.row(0).set_format(i, format_header)
      working_sheet.row(0).height = 25
      working_sheet.column(i).width = head_label[1]
    end

    #write table body content
    order.order_lines.each_with_index do |order_line, i|
      row = i + 1
      data_rows = [ order_line.commodity.name, order_line.commodity.pack_size, order_line.commodity.strength_dosage,
                    order_line.commodity.unit.name, order_line.number_of_client, order_line.stock_on_hand , 
                    order_line.monthly_use, order_line.system_suggestion, order_line.quantity_suggested,
                    order_line.status, order_line.user_data_entry_note, order_line.user_reviewer_note ]

      data_rows.each_with_index do |data, column|
        working_sheet[row, column] = data
      end
    end
  end

  def write_to_file(file_name)
    # at least one sheet is required to save excel
    @book.create_worksheet if @book.worksheets.empty?
    @book.write(file_name)
  end
end
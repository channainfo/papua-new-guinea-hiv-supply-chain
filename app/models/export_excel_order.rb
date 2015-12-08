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
    working_sheet_kit  = @book.create_worksheet name: "#{order.site.name}-kit"
    working_sheet_drug = @book.create_worksheet name: "#{order.site.name}-drug"
    
    #write table header with [cell_data, cell_width]
    head_labels = [ ["Commodity", 35], ["Quantity Per Package", 22], ["Pack Size", 10], ["Strength", 10], ["Unit", 10] , ["#Patient", 9], 
                    ["Stock on hand", 15], ["Monthly Use", 15], ["System Suggestion", 20],
                    ["Quantity Suggested", 20], ["Status", 10], ["Data Entry Note", 18], ["Reviewer note", 15] ]

    format_header_explain = Spreadsheet::Format.new color: :black, weight: :bold, size: 14, border: :thin,
                                            pattern_fg_color: :silver, pattern: 1

    format_header_title = Spreadsheet::Format.new color: :black, weight: :bold, size: 12, border: :thin,
                                            pattern_fg_color: :silver, pattern: 1

    [working_sheet_kit, working_sheet_drug].each do |working_sheet|

      working_sheet.row(0).height = 25
      working_sheet.merge_cells(0, 0, 0, 12)
      working_sheet.row(0).set_format(0, format_header_explain)
      working_sheet[0,0] = "Site: #{order.site.name}, Order No: #{order.order_number}"

      working_sheet.row(1).height = 25
      head_labels.each_with_index do |head_label, i|
        working_sheet[1,i] = head_label[0]
        working_sheet.row(1).set_format(i, format_header_title)
        working_sheet.column(i).width = head_label[1]
      end
    end

    #write table body content
    current_row_kit  = 2
    current_row_drug = 2

    order.order_lines.each_with_index do |order_line, i|
      data_rows = [ order_line.commodity.name,
                    order_line.commodity.quantity_per_packg,
                    order_line.commodity.pack_size,
                    order_line.commodity.strength_dosage,
                    order_line.commodity.unit.name,
                    order_line.number_of_client,
                    order_line.stock_on_hand,
                    order_line.monthly_use,
                    order_line.system_suggestion,
                    order_line.quantity_suggested,
                    order_line.status,
                    order_line.user_data_entry_note,
                    order_line.user_reviewer_note ]

      if order_line.kit? 
        working_sheet = working_sheet_kit
        row = current_row_kit
        current_row_kit += 1
      else
        working_sheet = working_sheet_drug
        row = current_row_drug
        current_row_drug += 1
      end

      data_rows.each_with_index do |data, column|
        working_sheet[row, column] = data
      end

    end
  end

  def write_to_file(file_name)
    # at least one sheet is required to save excel
    @book.create_worksheet(name: 'Sheet1') if @book.worksheets.empty?
    @book.write(file_name)
  end
end
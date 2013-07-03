module Admin::ApplicationHelper
  def app_name
    "Papua New Guinea National Department Of Health"
  end
  
  def app_title
     @app_title.nil? ?  app_name : (@app_title + " &raquo; ").html_safe + app_name
  end
  
  def page_header title, options={},  &block
     left_size  = options[:left] || 8
     right_size = options[:right] || (12 - left_size) 
    
     content_tag :div,:class => "row-fluid list-header" do
        if block_given? 
            content_title = content_tag :div, :class => "span#{left_size} left" do
              content_tag(:h3, title, :class => "header-title")
            end

            output = with_output_buffer(&block)
            content_link = content_tag(:div, output, {:class => "span#{right_size} right top-15"})
            content_title + content_link
        else
            content_tag :div , :class => "row-fluid" do 
               content_tag(:h3, title, :class => "header-title")
            end
        end 
     end
  end
  
  def paginate_records records
    content_tag :div , :class => "paginator right" do
      will_paginate records, renderer: BootstrapPagination::Rails
    end
  end
  
  def breadcrumb_str options
		items = []
		char_sep = "&raquo;".html_safe
		if( !options.nil?  && options.size != 0)
			items <<  content_tag(:li , :class => "active") do
				link_to("Home", admin_root_path) + content_tag(:span, char_sep, :class => "divider")
			end
			options.each do |option|
				option.each do |key, value|
				  if value
					items << content_tag(:li) do
						link_to(key, value) + content_tag(:span, char_sep, :class => "divider")
					end 
				  else
					  items << content_tag(:li, key, :class =>"active") 
				  end
				end
			end	
		else
			items << content_tag(:li, "Home", :class => "active")	
		end
		items.join("").html_safe
	end

	def breadcrumb options=nil
		content_tag(:ul, breadcrumb_str(options), :class => "breadcrumb")
	end


  def table_order_line body
    table = <<-EOD
      <table class='table table-striped well no-border no-padding'>
          <thead>
            <tr>
              <th width='240'> Commodity </th>
              <th> # Of Patient on Drug regiment </th>
              <th> Stock on hand</th>
              <th> Consumtion</th>
              <th> System Suggestion</th>
              <th> Quantity Suggested</th>
              <th> Entry Note</th>
            </tr>
          </thead>
          <tbody>
            #{body}
          </tbody>

      </table>
    EOD

    table.html_safe
  end
  
  
  
  
end

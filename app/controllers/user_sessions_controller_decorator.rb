UserSessionsController.class_eval do
  private

  def associate_user
    return unless current_user
    
    guest_order = current_order
    order = current_user.orders.where(:completed_at => nil).last
    
    if order
      if guest_order
        guest_order.line_items.each do |li|
          order.add_variant(li.variant, li.ad_hoc_option_values,
                            li.product_customizations, li.quantity)
        end
        
        order.save
        
        if session[:return_to]
          session[:return_to].gsub!(guest_order.number, order.number)
        end
        
        guest_order.destroy
      end
      
      session[:order_id] = order.id
    else
      guest_order.associate_user!(current_user) if guest_order
    end
    
    session[:guest_token] = nil
  end
end
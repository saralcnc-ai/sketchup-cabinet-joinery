# ============================================================================
# Cabinet Finger Joint Plugin for SketchUp - Version 4.0
# نمایه‌های اتصال کابینت با فینجر جوینت
# ============================================================================
# Version: 4.0 (No dialogs - Uses SketchUp menu only)
# Description: Creates finger joints for cabinet connections
# ============================================================================

module CabinetFingerJoint
  
  PLUGIN_NAME = "Cabinet Finger Joint"
  PLUGIN_VERSION = "4.0"
  
  # Measurements (in mm)
  FINGER_LENGTH = 120
  FINGER_WIDTH = 8
  FINGER_DEPTH = 10
  EXTRA_CLEARANCE = 0.5
  POCKET_DEPTH = FINGER_DEPTH + EXTRA_CLEARANCE
  EDGE_DISTANCE = 60
  
  @body_component = nil
  @shelf_component = nil
  @preview_group = nil
  
  class << self
    
    def start_workflow
      # Automatically open the main menu with submenus
      add_menu_items
      show_status_message
    end
    
    def add_menu_items
      unless @menu_added
        plugins_menu = UI.menu("Plugins")
        submenu = plugins_menu.add_submenu("Cabinet Finger Joint")
        
        submenu.add_item("1. انتخاب بدنه (Select Body)") { select_body_component }
        submenu.add_item("2. انتخاب شلف (Select Shelf)") { select_shelf_component }
        submenu.add_item("-") {}
        submenu.add_item("3. پیش‌نمایش (Preview)") { show_preview_geometry }
        submenu.add_item("4. اعمال فینجر جوینت (Apply)") { apply_joints_final }
        submenu.add_item("-") {}
        submenu.add_item("وضعیت (Status)") { show_status }
        submenu.add_item("پاک کردن (Clear)") { cleanup }
        
        @menu_added = true
      end
    end
    
    def show_status_message
      body_name = @body_component ? @body_component.name : "---"
      shelf_name = @shelf_component ? @shelf_component.name : "---"
      
      puts "=" * 60
      puts "Cabinet Finger Joint - #{PLUGIN_VERSION}"
      puts "=" * 60
      puts "بدنه: #{body_name}"
      puts "شلف: #{shelf_name}"
      puts ""
      puts "مراحل:"
      puts "1. Plugins → Cabinet Finger Joint → انتخاب بدنه"
      puts "2. بدنه را کلیک کنید"
      puts "3. Plugins → Cabinet Finger Joint → انتخاب شلف"
      puts "4. شلف را کلیک کنید"
      puts "5. Plugins → Cabinet Finger Joint → پیش‌نمایش"
      puts "6. Plugins → Cabinet Finger Joint → اعمال"
      puts "=" * 60
    end
    
    def show_status
      body_info = @body_component ? "✓ #{@body_component.name}" : "❌ انتخاب نشده"
      shelf_info = @shelf_component ? "✓ #{@shelf_component.name}" : "❌ انتخاب نشده"
      
      message = "وضعیت:\n\n" +
                "بدنه: #{body_info}\n" +
                "شلف: #{shelf_info}\n\n" +
                "مرحله بعدی:\n"
      
      if @body_component.nil?
        message += "1. بدنه را انتخاب کنید"
      elsif @shelf_component.nil?
        message += "2. شلف را انتخاب کنید"
      else
        message += "3. پیش‌نمایش یا اعمال را انتخاب کنید"
      end
      
      puts message
    end
    
    def select_body_component
      model = Sketchup.active_model
      selection = model.selection
      
      if selection.length == 0
        puts "❌ هیچ چیزی انتخاب نشد! لطفاً بدنه کابینت را کلیک کنید."
        return
      end
      
      entity = selection[0]
      
      if !entity.is_a?(Sketchup::ComponentInstance)
        puts "❌ خطا: لطفاً یک کمپوننت انتخاب کنید"
        return
      end
      
      @body_component = entity
      selection.clear
      
      bounds = @body_component.bounds
      dims = {
        length: (bounds.max.x - bounds.min.x).to_mm.round(0),
        width: (bounds.max.y - bounds.min.y).to_mm.round(0),
        height: (bounds.max.z - bounds.min.z).to_mm.round(0)
      }
      
      puts "✓ بدنه انتخاب شد!"
      puts "  نام: #{@body_component.name}"
      puts "  ابعاد: #{dims[:length]} × #{dims[:width]} × #{dims[:height]} mm"
    end
    
    def select_shelf_component
      model = Sketchup.active_model
      selection = model.selection
      
      if selection.length == 0
        puts "❌ هیچ چیزی انتخاب نشد! لطفاً شلف را کلیک کنید."
        return
      end
      
      entity = selection[0]
      
      if !entity.is_a?(Sketchup::ComponentInstance)
        puts "❌ خطا: لطفاً یک کمپوننت انتخاب کنید"
        return
      end
      
      @shelf_component = entity
      selection.clear
      
      bounds = @shelf_component.bounds
      dims = {
        length: (bounds.max.x - bounds.min.x).to_mm.round(0),
        width: (bounds.max.y - bounds.min.y).to_mm.round(0),
        height: (bounds.max.z - bounds.min.z).to_mm.round(0)
      }
      
      puts "✓ شلف انتخاب شد!"
      puts "  نام: #{@shelf_component.name}"
      puts "  ابعاد: #{dims[:length]} × #{dims[:width]} × #{dims[:height]} mm"
    end
    
    def show_preview_geometry
      if @body_component.nil? || @shelf_component.nil?
        puts "❌ خطا: ابتدا بدنه و شلف را انتخاب کنید!"
        return
      end
      
      model = Sketchup.active_model
      
      # Remove old preview
      if @preview_group
        model.active_entities.erase_entities(@preview_group)
      end
      
      # Create new preview
      @preview_group = model.active_entities.add_group
      @preview_group.name = "Finger Joint Preview"
      
      begin
        create_preview_fingers(@preview_group, @shelf_component, model)
        puts "👁️ پیش‌نمایش نمایش داده شد"
        puts "اگر درست است، 'اعمال' را انتخاب کنید"
        puts "اگر غلط است، 'پاک کردن' را انتخاب کنید"
      rescue => error
        if @preview_group
          model.active_entities.erase_entities(@preview_group)
          @preview_group = nil
        end
        puts "❌ خطا: #{error.message}"
      end
    end
    
    def apply_joints_final
      if @body_component.nil? || @shelf_component.nil?
        puts "❌ خطا: ابتدا بدنه و شلف را انتخاب کنید!"
        return
      end
      
      model = Sketchup.active_model
      
      # Remove preview if exists
      if @preview_group
        model.active_entities.erase_entities(@preview_group)
        @preview_group = nil
      end
      
      model.start_operation("Apply Finger Joints", true)
      
      begin
        create_fingers_on_shelf(@shelf_component, model)
        create_pockets_on_body(@body_component, @shelf_component, model)
        model.commit_operation
        
        puts "✅ موفق!"
        puts "فینجر جوینت ایجاد شد:"
        puts "  • شلف: 2 انگشت اضافه شد"
        puts "  • بدنه: 2 جای انگشت حفر شد"
        
        cleanup
        
      rescue => error
        model.abort_operation
        puts "❌ خطا: #{error.message}"
      end
    end
    
    def cleanup
      @body_component = nil
      @shelf_component = nil
      if @preview_group
        Sketchup.active_model.active_entities.erase_entities(@preview_group)
        @preview_group = nil
      end
      puts "✓ پاک شد"
    end
    
    private
    
    def create_preview_fingers(preview_group, shelf_component, model)
      preview_entities = preview_group.entities
      shelf_bounds = shelf_component.bounds
      
      # Front finger
      front_y = shelf_bounds.min.y + EDGE_DISTANCE.mm
      draw_preview_box(
        preview_entities,
        shelf_bounds.min.x,
        front_y,
        shelf_bounds.min.z,
        FINGER_LENGTH.mm,
        FINGER_WIDTH.mm,
        FINGER_DEPTH.mm
      )
      
      # Back finger
      back_y = shelf_bounds.max.y - EDGE_DISTANCE.mm - FINGER_WIDTH.mm
      draw_preview_box(
        preview_entities,
        shelf_bounds.min.x,
        back_y,
        shelf_bounds.min.z,
        FINGER_LENGTH.mm,
        FINGER_WIDTH.mm,
        FINGER_DEPTH.mm
      )
    end
    
    def draw_preview_box(entities, x, y, z, length, width, height)
      points = [
        Geom::Point3d.new(x, y, z),
        Geom::Point3d.new(x + length, y, z),
        Geom::Point3d.new(x + length, y + width, z),
        Geom::Point3d.new(x, y + width, z)
      ]
      
      face = entities.add_face(points)
      face.reverse! if face.normal.z < 0
      face.pushpull(height, true)
    end
    
    def create_fingers_on_shelf(shelf_component, model)
      shelf_definition = shelf_component.definition
      entities = shelf_definition.entities
      shelf_bounds = shelf_component.bounds
      
      # Front finger
      create_single_finger(
        entities,
        shelf_bounds.min.x,
        shelf_bounds.min.y + EDGE_DISTANCE.mm,
        shelf_bounds.min.z,
        "Front Finger"
      )
      
      # Back finger
      create_single_finger(
        entities,
        shelf_bounds.min.x,
        shelf_bounds.max.y - EDGE_DISTANCE.mm - FINGER_WIDTH.mm,
        shelf_bounds.min.z,
        "Back Finger"
      )
    end
    
    def create_single_finger(entities, x_start, y_start, z_start, name)
      x_end = x_start + FINGER_LENGTH.mm
      y_end = y_start + FINGER_WIDTH.mm
      z_end = z_start + FINGER_DEPTH.mm
      
      points = [
        Geom::Point3d.new(x_start, y_start, z_start),
        Geom::Point3d.new(x_end, y_start, z_start),
        Geom::Point3d.new(x_end, y_end, z_start),
        Geom::Point3d.new(x_start, y_end, z_start)
      ]
      
      face = entities.add_face(points)
      face.reverse! if face.normal.z < 0
      push_result = face.pushpull(FINGER_DEPTH.mm, true)
      
      if push_result.is_a?(Array)
        push_result.each { |entity| entity.name = name if entity.respond_to?(:name=) }
      elsif push_result && push_result.respond_to?(:name=)
        push_result.name = name
      end
    end
    
    def create_pockets_on_body(body_component, shelf_component, model)
      body_definition = body_component.definition
      entities = body_definition.entities
      shelf_bounds = shelf_component.bounds
      
      # Front pocket
      create_single_pocket(
        entities,
        shelf_bounds.min.x,
        shelf_bounds.min.y + EDGE_DISTANCE.mm,
        shelf_bounds.min.z,
        "Front Pocket"
      )
      
      # Back pocket
      create_single_pocket(
        entities,
        shelf_bounds.min.x,
        shelf_bounds.max.y - EDGE_DISTANCE.mm - FINGER_WIDTH.mm,
        shelf_bounds.min.z,
        "Back Pocket"
      )
    end
    
    def create_single_pocket(entities, x_start, y_start, z_start, name)
      x_end = x_start + FINGER_LENGTH.mm
      y_end = y_start + FINGER_WIDTH.mm + EXTRA_CLEARANCE.mm
      z_end = z_start + POCKET_DEPTH.mm
      
      points = [
        Geom::Point3d.new(x_start, y_start, z_end),
        Geom::Point3d.new(x_end, y_start, z_end),
        Geom::Point3d.new(x_end, y_end, z_end),
        Geom::Point3d.new(x_start, y_end, z_end)
      ]
      
      face = entities.add_face(points)
      face.reverse! if face.normal.z > 0
      push_result = face.pushpull(-(POCKET_DEPTH.mm), true)
      
      if push_result.is_a?(Array)
        push_result.each { |entity| entity.name = name if entity.respond_to?(:name=) }
      elsif push_result && push_result.respond_to?(:name=)
        push_result.name = name
      end
    end
  end
  
  unless file_loaded?(__FILE__)
    menu = UI.menu("Plugins")
    menu.add_item("Cabinet Finger Joint") do
      CabinetFingerJoint.start_workflow
    end
    file_loaded(__FILE__)
  end
end

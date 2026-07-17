# ============================================================================
# Cabinet Finger Joint Plugin for SketchUp - Version 3.2
# نمایه‌های اتصال کابینت با فینجر جوینت
# ============================================================================
# Version: 3.2 (Fixed UI - Dialog closes for selection)
# Description: Creates finger joints for cabinet connections with simple UI
# ============================================================================

module CabinetFingerJoint
  
  PLUGIN_NAME = "Cabinet Finger Joint"
  PLUGIN_VERSION = "3.2"
  
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
      show_main_menu
    end
    
    def show_main_menu
      loop do
        body_status = @body_component ? "✓ انتخاب شد: #{@body_component.name}" : "❌ انتخاب نشده"
        shelf_status = @shelf_component ? "✓ انتخاب شد: #{@shelf_component.name}" : "❌ انتخاب نشده"
        
        message = "فینجر جوینت کابینت - نسخه #{PLUGIN_VERSION}\n\n" +
                  "وضعیت:\n" +
                  "بدنه: #{body_status}\n" +
                  "شلف: #{shelf_status}\n\n" +
                  "گزینه‌ها:\n" +
                  "1 = انتخاب بدنه\n" +
                  "2 = انتخاب شلف\n" +
                  "3 = پیش‌نمایش\n" +
                  "4 = اعمال\n" +
                  "5 = خروج\n\n" +
                  "کدام گزینه؟"
        
        result = UI.inputbox(
          ["انتخاب"],
          ["1"],
          message
        )
        
        return if result.nil?
        
        choice = result[0].to_i
        
        case choice
        when 1
          select_body_component
        when 2
          select_shelf_component
        when 3
          show_preview_geometry
        when 4
          apply_joints_final
          return
        when 5
          cleanup
          return
        else
          UI.messagebox("گزینه نامعتبر! لطفاً 1 تا 5 را انتخاب کنید.", MB_OK, PLUGIN_NAME)
        end
      end
    end
    
    def select_body_component
      model = Sketchup.active_model
      
      # Clear selection first
      model.selection.clear
      
      UI.messagebox(
        "✓ در حالا بدنه کابینت را کلیک کنید\n\n" +
        "سپس OK کلیک کنید تا ادامه دهیم",
        MB_OK,
        PLUGIN_NAME
      )
      
      # Wait for user to select something
      wait_for_selection
      
      if model.selection.length > 0
        entity = model.selection[0]
        
        if entity.is_a?(Sketchup::ComponentInstance)
          @body_component = entity
          model.selection.clear
          
          bounds = @body_component.bounds
          dims = {
            length: (bounds.max.x - bounds.min.x).to_mm.round(0),
            width: (bounds.max.y - bounds.min.y).to_mm.round(0),
            height: (bounds.max.z - bounds.min.z).to_mm.round(0)
          }
          
          UI.messagebox(
            "✓ بدنه انتخاب شد!\n\n" +
            "نام: #{@body_component.name}\n" +
            "ابعاد: #{dims[:length]} × #{dims[:width]} × #{dims[:height]} mm",
            MB_OK,
            PLUGIN_NAME
          )
        else
          UI.messagebox(
            "❌ خطا: لطفاً یک کمپوننت انتخاب کنید، نه یک گروپ یا شی دیگر",
            MB_OK,
            PLUGIN_NAME
          )
        end
      else
        UI.messagebox(
          "❌ هیچ چیزی انتخاب نشد!",
          MB_OK,
          PLUGIN_NAME
        )
      end
    end
    
    def select_shelf_component
      model = Sketchup.active_model
      
      # Clear selection first
      model.selection.clear
      
      UI.messagebox(
        "✓ حالا شلف را کلیک کنید\n\n" +
        "سپس OK کلیک کنید تا ادامه دهیم",
        MB_OK,
        PLUGIN_NAME
      )
      
      # Wait for user to select something
      wait_for_selection
      
      if model.selection.length > 0
        entity = model.selection[0]
        
        if entity.is_a?(Sketchup::ComponentInstance)
          @shelf_component = entity
          model.selection.clear
          
          bounds = @shelf_component.bounds
          dims = {
            length: (bounds.max.x - bounds.min.x).to_mm.round(0),
            width: (bounds.max.y - bounds.min.y).to_mm.round(0),
            height: (bounds.max.z - bounds.min.z).to_mm.round(0)
          }
          
          UI.messagebox(
            "✓ شلف انتخاب شد!\n\n" +
            "نام: #{@shelf_component.name}\n" +
            "ابعاد: #{dims[:length]} × #{dims[:width]} × #{dims[:height]} mm\n\n" +
            "انگشت‌ها در جهت عرض شلف قرار می‌گیرند",
            MB_OK,
            PLUGIN_NAME
          )
        else
          UI.messagebox(
            "❌ خطا: لطفاً یک کمپوننت انتخاب کنید، نه یک گروپ یا شی دیگر",
            MB_OK,
            PLUGIN_NAME
          )
        end
      else
        UI.messagebox(
          "❌ هیچ چیزی انتخاب نشد!",
          MB_OK,
          PLUGIN_NAME
        )
      end
    end
    
    def wait_for_selection
      # Simple wait - user will click OK after selecting
      sleep(0.5)
    end
    
    def show_preview_geometry
      if @body_component.nil? || @shelf_component.nil?
        UI.messagebox(
          "❌ خطا: لطفاً ابتدا بدنه و شلف را انتخاب کنید!",
          MB_OK,
          PLUGIN_NAME
        )
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
        
        result = UI.messagebox(
          "👁️ پیش‌نمایش نمایش داده شد\n\n" +
          "آیا این درست است؟",
          MB_YESNO,
          PLUGIN_NAME
        )
        
        if result == IDNO
          model.active_entities.erase_entities(@preview_group)
          @preview_group = nil
          UI.messagebox(
            "پیش‌نمایش حذف شد.\n\n" +
            "می‌توانید دوباره انتخاب کنید یا تنظیمات را تغییر دهید.",
            MB_OK,
            PLUGIN_NAME
          )
        end
        
      rescue => error
        if @preview_group
          model.active_entities.erase_entities(@preview_group)
          @preview_group = nil
        end
        UI.messagebox("❌ خطا: #{error.message}", MB_OK, PLUGIN_NAME)
      end
    end
    
    def apply_joints_final
      if @body_component.nil? || @shelf_component.nil?
        UI.messagebox(
          "❌ خطا: لطفاً ابتدا بدنه و شلف را انتخاب کنید!",
          MB_OK,
          PLUGIN_NAME
        )
        return
      end
      
      model = Sketchup.active_model
      
      # Remove preview if exists
      if @preview_group
        model.active_entities.erase_entities(@preview_group)
        @preview_group = nil
      end
      
      result = UI.messagebox(
        "⚠️ آیا مطمئن هستید؟\n\n" +
        "فینجر‌جوینت ایجاد می‌شود...",
        MB_YESNO,
        PLUGIN_NAME
      )
      
      return if result == IDNO
      
      model.start_operation("Apply Finger Joints", true)
      
      begin
        create_fingers_on_shelf(@shelf_component, model)
        create_pockets_on_body(@body_component, @shelf_component, model)
        model.commit_operation
        
        UI.messagebox(
          "✅ موفق!\n\n" +
          "فینجر‌جوینت ایجاد شد:\n" +
          "• شلف: 2 انگشت اضافه شد\n" +
          "• بدنه: 2 جای انگشت حفر شد",
          MB_OK,
          PLUGIN_NAME
        )
        
        cleanup
        
      rescue => error
        model.abort_operation
        UI.messagebox("❌ خطا: #{error.message}", MB_OK, PLUGIN_NAME)
      end
    end
    
    def cleanup
      @body_component = nil
      @shelf_component = nil
      if @preview_group
        Sketchup.active_model.active_entities.erase_entities(@preview_group)
        @preview_group = nil
      end
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

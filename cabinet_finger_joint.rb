# ============================================================================
# Cabinet Finger Joint Plugin for SketchUp
# نمایه‌های اتصال کابینت با فینجر جوینت
# ============================================================================
# Version: 2.0
# Description: Creates finger joints for cabinet connections
# Features:
#   - Interactive step-by-step component selection
#   - Live preview of finger joints
#   - 2 fingers (one front, one back)
#   - 12cm finger length along shelf width
#   - 6cm distance from edges
#   - Symmetrical on shelf component
#   - Automatic pocket cutting on cabinet body
# ============================================================================

module CabinetFingerJoint
  
  # Plugin metadata
  PLUGIN_NAME = "Cabinet Finger Joint"
  PLUGIN_VERSION = "2.0"
  
  # Measurements (in mm)
  FINGER_LENGTH = 120      # 12cm
  FINGER_WIDTH = 8         # 8mm
  FINGER_DEPTH = 10        # 10mm on body
  EXTRA_CLEARANCE = 0.5    # 0.5mm extra for easy fit
  POCKET_DEPTH = FINGER_DEPTH + EXTRA_CLEARANCE
  EDGE_DISTANCE = 60       # 6cm from edges
  
  class << self
    
    # Main entry point
    def start_workflow
      model = Sketchup.active_model
      
      # Step 1: Select base part (body)
      UI.messagebox(
        "مرحله 1: بدنه کابینت را انتخاب کنید\n\n" +
        "Step 1: Select the CABINET BODY component\n\n" +
        "سپس OK کلیک کنید.",
        MB_OK,
        PLUGIN_NAME
      )
      
      model.selection.clear
      body_component = wait_for_selection("base part")
      
      if body_component.nil?
        UI.messagebox("بدنه انتخاب نشد. لغو شد.", MB_OK, PLUGIN_NAME)
        return
      end
      
      # Step 2: Select shelf
      UI.messagebox(
        "مرحله 2: شلف را انتخاب کنید\n\n" +
        "Step 2: Select the SHELF component\n\n" +
        "سپس OK کلیک کنید.",
        MB_OK,
        PLUGIN_NAME
      )
      
      model.selection.clear
      shelf_component = wait_for_selection("shelf")
      
      if shelf_component.nil?
        UI.messagebox("شلف انتخاب نشد. لغو شد.", MB_OK, PLUGIN_NAME)
        return
      end
      
      # Show dimensions
      show_dimensions(body_component, shelf_component, model)
      
      # Create preview
      show_preview(body_component, shelf_component, model)
    end
    
    private
    
    def wait_for_selection(component_type)
      model = Sketchup.active_model
      timeout = Time.now + 60  # 60 second timeout
      
      loop do
        if model.selection.length > 0
          entity = model.selection[0]
          if entity.is_a?(Sketchup::ComponentInstance)
            model.selection.clear
            return entity
          end
        end
        
        if Time.now > timeout
          return nil
        end
        
        sleep(0.1)
      end
    end
    
    def show_dimensions(body_component, shelf_component, model)
      body_bounds = body_component.bounds
      shelf_bounds = shelf_component.bounds
      
      body_dims = {
        length: (body_bounds.max.x - body_bounds.min.x).to_mm.round(2),
        width: (body_bounds.max.y - body_bounds.min.y).to_mm.round(2),
        height: (body_bounds.max.z - body_bounds.min.z).to_mm.round(2)
      }
      
      shelf_dims = {
        length: (shelf_bounds.max.x - shelf_bounds.min.x).to_mm.round(2),
        width: (shelf_bounds.max.y - shelf_bounds.min.y).to_mm.round(2),
        height: (shelf_bounds.max.z - shelf_bounds.min.z).to_mm.round(2)
      }
      
      message = "ابعاد تشخیص داده شده:\n\n" +
                "Detected Dimensions:\n\n" +
                "بدنه (Base Part):\n" +
                "  طول: #{body_dims[:length]} mm\n" +
                "  عرض: #{body_dims[:width]} mm\n" +
                "  ارتفاع: #{body_dims[:height]} mm\n\n" +
                "شلف (Shelf):\n" +
                "  طول: #{shelf_dims[:length]} mm\n" +
                "  عرض: #{shelf_dims[:width]} mm\n" +
                "  ارتفاع: #{shelf_dims[:height]} mm\n\n" +
                "انگشت‌ها در جهت عرض شلف:\n" +
                "Fingers along shelf width: #{shelf_dims[:width]} mm"
      
      UI.messagebox(message, MB_OK, PLUGIN_NAME)
    end
    
    def show_preview(body_component, shelf_component, model)
      # Create preview group
      entities = model.active_entities
      preview_group = entities.add_group
      preview_group.name = "Finger Joint Preview"
      
      begin
        # Draw preview geometry
        create_preview_fingers(preview_group, shelf_component, body_component, model)
        
        # Ask user for confirmation
        result = UI.messagebox(
          "پیش‌نمایش نمایش داده شد.\n\n" +
          "Preview shown above.\n\n" +
          "آیا مایل به اعمال فینجر جوینت هستید؟\n" +
          "Apply finger joints?",
          MB_YESNO,
          PLUGIN_NAME
        )
        
        if result == IDYES
          # Remove preview
          entities.erase_entities(preview_group)
          
          # Apply actual finger joints
          model.start_operation("Apply Finger Joints", true)
          begin
            create_fingers_on_shelf(shelf_component, model)
            create_pockets_on_body(body_component, shelf_component, model)
            model.commit_operation
            
            UI.messagebox(
              "فینجر جوینت‌ها با موفقیت اعمال شدند!\n\n" +
              "Finger joints applied successfully!",
              MB_OK,
              PLUGIN_NAME
            )
          rescue => error
            model.abort_operation
            UI.messagebox("خطا: #{error.message}", MB_OK, PLUGIN_NAME)
          end
        else
          # Remove preview
          entities.erase_entities(preview_group)
        end
        
      rescue => error
        entities.erase_entities(preview_group)
        UI.messagebox("خطا در پیش‌نمایش: #{error.message}", MB_OK, PLUGIN_NAME)
      end
    end
    
    def create_preview_fingers(preview_group, shelf_component, body_component, model)
      preview_entities = preview_group.entities
      shelf_bounds = shelf_component.bounds
      
      # Get shelf dimensions
      shelf_width = shelf_bounds.max.y - shelf_bounds.min.y
      shelf_length = shelf_bounds.max.x - shelf_bounds.min.x
      
      # Front finger preview
      front_y = shelf_bounds.min.y + EDGE_DISTANCE.mm
      draw_preview_box(
        preview_entities,
        shelf_bounds.min.x,
        front_y,
        shelf_bounds.min.z,
        FINGER_LENGTH.mm,
        FINGER_WIDTH.mm,
        FINGER_DEPTH.mm,
        "Front Finger Preview"
      )
      
      # Back finger preview
      back_y = shelf_bounds.max.y - EDGE_DISTANCE.mm - FINGER_WIDTH.mm
      draw_preview_box(
        preview_entities,
        shelf_bounds.min.x,
        back_y,
        shelf_bounds.min.z,
        FINGER_LENGTH.mm,
        FINGER_WIDTH.mm,
        FINGER_DEPTH.mm,
        "Back Finger Preview"
      )
    end
    
    def draw_preview_box(entities, x, y, z, length, width, height, name)
      points = [
        Geom::Point3d.new(x, y, z),
        Geom::Point3d.new(x + length, y, z),
        Geom::Point3d.new(x + length, y + width, z),
        Geom::Point3d.new(x, y + width, z)
      ]
      
      face = entities.add_face(points)
      face.reverse! if face.normal.z < 0
      
      # Extrude to show height
      face.pushpull(height, true)
    end
    
    # Create two fingers on the shelf component
    def create_fingers_on_shelf(shelf_component, model)
      shelf_definition = shelf_component.definition
      entities = shelf_definition.entities
      shelf_bounds = shelf_component.bounds
      
      # Get shelf dimensions
      shelf_width = shelf_bounds.max.y - shelf_bounds.min.y
      
      # Front finger
      create_single_finger(
        entities,
        shelf_bounds.min.x,
        shelf_bounds.min.y + EDGE_DISTANCE.mm,
        shelf_bounds.min.z,
        "Front Finger"
      )
      
      # Back finger (symmetrical from back edge)
      create_single_finger(
        entities,
        shelf_bounds.min.x,
        shelf_bounds.max.y - EDGE_DISTANCE.mm - FINGER_WIDTH.mm,
        shelf_bounds.min.z,
        "Back Finger"
      )
    end
    
    # Create a single finger (box extrusion)
    def create_single_finger(entities, x_start, y_start, z_start, name)
      x_end = x_start + FINGER_LENGTH.mm
      y_end = y_start + FINGER_WIDTH.mm
      z_end = z_start + FINGER_DEPTH.mm
      
      # Create rectangle face for the finger
      points = [
        Geom::Point3d.new(x_start, y_start, z_start),
        Geom::Point3d.new(x_end, y_start, z_start),
        Geom::Point3d.new(x_end, y_end, z_start),
        Geom::Point3d.new(x_start, y_end, z_start)
      ]
      
      # Create face
      face = entities.add_face(points)
      face.reverse! if face.normal.z < 0
      
      # Push face to create 3D finger
      push_result = face.pushpull(FINGER_DEPTH.mm, true)
      
      # Name the group/component
      if push_result.is_a?(Array)
        push_result.each { |entity| entity.name = name if entity.respond_to?(:name=) }
      elsif push_result && push_result.respond_to?(:name=)
        push_result.name = name
      end
    end
    
    # Create pockets on the body component
    def create_pockets_on_body(body_component, shelf_component, model)
      body_definition = body_component.definition
      entities = body_definition.entities
      shelf_bounds = shelf_component.bounds
      
      # Get shelf dimensions
      shelf_width = shelf_bounds.max.y - shelf_bounds.min.y
      
      # Front pocket
      create_single_pocket(
        entities,
        shelf_bounds.min.x,
        shelf_bounds.min.y + EDGE_DISTANCE.mm,
        shelf_bounds.min.z,
        "Front Pocket"
      )
      
      # Back pocket (symmetrical)
      create_single_pocket(
        entities,
        shelf_bounds.min.x,
        shelf_bounds.max.y - EDGE_DISTANCE.mm - FINGER_WIDTH.mm,
        shelf_bounds.min.z,
        "Back Pocket"
      )
    end
    
    # Create a single pocket (indentation) on the body
    def create_single_pocket(entities, x_start, y_start, z_start, name)
      x_end = x_start + FINGER_LENGTH.mm
      y_end = y_start + FINGER_WIDTH.mm + EXTRA_CLEARANCE.mm
      z_end = z_start + POCKET_DEPTH.mm
      
      # Create rectangle face for the pocket
      points = [
        Geom::Point3d.new(x_start, y_start, z_end),
        Geom::Point3d.new(x_end, y_start, z_end),
        Geom::Point3d.new(x_end, y_end, z_end),
        Geom::Point3d.new(x_start, y_end, z_end)
      ]
      
      # Create face
      face = entities.add_face(points)
      face.reverse! if face.normal.z > 0
      
      # Push face inward to create pocket
      push_result = face.pushpull(-(POCKET_DEPTH.mm), true)
      
      # Name the group/component
      if push_result.is_a?(Array)
        push_result.each { |entity| entity.name = name if entity.respond_to?(:name=) }
      elsif push_result && push_result.respond_to?(:name=)
        push_result.name = name
      end
    end
  end
  
  # Add menu items
  unless file_loaded?(__FILE__)
    menu = UI.menu("Plugins")
    menu.add_item("Cabinet Finger Joint") do
      CabinetFingerJoint.start_workflow
    end
    file_loaded(__FILE__)
  end
end
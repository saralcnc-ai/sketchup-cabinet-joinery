# ============================================================================
# Cabinet Finger Joint Plugin for SketchUp - Version 5.0
# نمایه‌های اتصال کابینت با فینجر جوینت
# ============================================================================
# Version: 5.0 (Pure Ruby - No Windows - Console only)
# Description: Creates finger joints for cabinet connections
# ============================================================================

module CabinetFingerJoint
  
  PLUGIN_NAME = "Cabinet Finger Joint"
  PLUGIN_VERSION = "5.0"
  
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
      add_menu_items
      show_welcome_message
    end
    
    def add_menu_items
      unless @menu_added
        plugins_menu = UI.menu("Plugins")
        submenu = plugins_menu.add_submenu("Cabinet Finger Joint")
        
        submenu.add_item("1. Select Body | انتخاب بدنه") { select_body_component }
        submenu.add_item("2. Select Shelf | انتخاب شلف") { select_shelf_component }
        submenu.add_item("-") {}
        submenu.add_item("3. Preview | پیش‌نمایش") { show_preview_geometry }
        submenu.add_item("4. Apply | اعمال") { apply_joints_final }
        submenu.add_item("-") {}
        submenu.add_item("Status | وضعیت") { show_status }
        submenu.add_item("Clear | پاک کردن") { cleanup }
        
        @menu_added = true
      end
    end
    
    def show_welcome_message
      puts "\n"
      puts "=" * 70
      puts "Cabinet Finger Joint - Version #{PLUGIN_VERSION}".center(70)
      puts "=" * 70
      puts ""
      puts "روشن شد! به مراحل زیر عمل کنید:".center(70)
      puts ""
      puts "STEP 1: Click Body in the model, then:".ljust(70)
      puts "        Plugins → Cabinet Finger Joint → 1. Select Body".ljust(70)
      puts ""
      puts "STEP 2: Click Shelf in the model, then:".ljust(70)
      puts "        Plugins → Cabinet Finger Joint → 2. Select Shelf".ljust(70)
      puts ""
      puts "STEP 3: Plugins → Cabinet Finger Joint → 3. Preview".ljust(70)
      puts ""
      puts "STEP 4: Plugins → Cabinet Finger Joint → 4. Apply".ljust(70)
      puts ""
      puts "=" * 70
      puts ""
    end
    
    def select_body_component
      model = Sketchup.active_model
      selection = model.selection
      
      puts "\n--- SELECT BODY | انتخاب بدنه ---"
      
      if selection.length == 0
        puts "❌ ERROR: No component selected!"
        puts "❌ خطا: هیچ چیزی انتخاب نشد!"
        return
      end
      
      entity = selection[0]
      
      if !entity.is_a?(Sketchup::ComponentInstance)
        puts "❌ ERROR: Must select a component, not a group!"
        puts "❌ خطا: فقط کمپوننت انتخاب کنید!"
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
      
      puts "✓ Body selected successfully! | بدنه انتخاب شد!"
      puts "  Name: #{@body_component.name}"
      puts "  Size: #{dims[:length]} × #{dims[:width]} × #{dims[:height]} mm"
      puts ""
    end
    
    def select_shelf_component
      model = Sketchup.active_model
      selection = model.selection
      
      puts "\n--- SELECT SHELF | انتخاب شلف ---"
      
      if selection.length == 0
        puts "❌ ERROR: No component selected!"
        puts "❌ خطا: هیچ چیزی انتخاب نشد!"
        return
      end
      
      entity = selection[0]
      
      if !entity.is_a?(Sketchup::ComponentInstance)
        puts "❌ ERROR: Must select a component, not a group!"
        puts "❌ خطا: فقط کمپوننت انتخاب کنید!"
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
      
      puts "✓ Shelf selected successfully! | شلف انتخاب شد!"
      puts "  Name: #{@shelf_component.name}"
      puts "  Size: #{dims[:length]} × #{dims[:width]} × #{dims[:height]} mm"
      puts "  Fingers will be placed along shelf width (عرض شلف)"
      puts ""
    end
    
    def show_status
      body_info = @body_component ? "✓ #{@body_component.name}" : "❌ Not selected"
      shelf_info = @shelf_component ? "✓ #{@shelf_component.name}" : "❌ Not selected"
      
      puts "\n--- STATUS | وضعیت ---"
      puts "Body | بدنه: #{body_info}"
      puts "Shelf | شلف: #{shelf_info}"
      
      if @body_component.nil?
        puts "\nNext step: Select body and click 'Select Body'"
      elsif @shelf_component.nil?
        puts "\nNext step: Select shelf and click 'Select Shelf'"
      else
        puts "\nNext step: Click 'Preview' to see the result"
      end
      puts ""
    end
    
    def show_preview_geometry
      if @body_component.nil? || @shelf_component.nil?
        puts "\n❌ ERROR: Select both body and shelf first!"
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
        
        puts "\n--- PREVIEW | پیش‌نمایش ---"
        puts "✓ Preview created! | پیش‌نمایش نمایش داده شد!"
        puts "  • Front finger: 60mm from front edge"
        puts "  • Back finger: 60mm from back edge"
        puts "  • Finger length: 120mm"
        puts "  • Finger width: 8mm"
        puts "  • Finger depth: 10mm"
        puts ""
        puts "If correct → Click 'Apply | اعمال'"
        puts "If wrong → Click 'Clear | پاک کردن' and try again"
        puts ""
        
      rescue => error
        if @preview_group
          model.active_entities.erase_entities(@preview_group)
          @preview_group = nil
        end
        puts "❌ ERROR: #{error.message}"
      end
    end
    
    def apply_joints_final
      if @body_component.nil? || @shelf_component.nil?
        puts "\n❌ ERROR: Select both body and shelf first!"
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
        puts "\n--- APPLYING | در حال اعمال ---"
        
        create_fingers_on_shelf(@shelf_component, model)
        puts "  ✓ Fingers added to shelf"
        
        create_pockets_on_body(@body_component, @shelf_component, model)
        puts "  ✓ Pockets created on body"
        
        model.commit_operation
        
        puts ""
        puts "✅ SUCCESS! | موفق!"
        puts "Finger joints created successfully!"
        puts "فینجر جوینت‌ها با موفقیت ایجاد شدند!"
        puts ""
        
        cleanup
        
      rescue => error
        model.abort_operation
        puts "❌ ERROR: #{error.message}"
      end
    end
    
    def cleanup
      @body_component = nil
      @shelf_component = nil
      if @preview_group
        Sketchup.active_model.active_entities.erase_entities(@preview_group)
        @preview_group = nil
      end
      puts "✓ Cleared | پاک شد"
      puts ""
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

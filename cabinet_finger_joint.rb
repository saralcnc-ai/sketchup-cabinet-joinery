# ============================================================================
# Cabinet Finger Joint Plugin for SketchUp - Version 3.0
# نمایه‌های اتصال کابینت با فینجر جوینت
# ============================================================================
# Version: 3.0 (Complete Rewrite with UI Dialog)
# Description: Creates finger joints for cabinet connections
# Features:
#   - Dialog-based UI with buttons
#   - Fast component selection
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
  PLUGIN_VERSION = "3.0"
  
  # Measurements (in mm)
  FINGER_LENGTH = 120      # 12cm
  FINGER_WIDTH = 8         # 8mm
  FINGER_DEPTH = 10        # 10mm on body
  EXTRA_CLEARANCE = 0.5    # 0.5mm extra for easy fit
  POCKET_DEPTH = FINGER_DEPTH + EXTRA_CLEARANCE
  EDGE_DISTANCE = 60       # 6cm from edges
  
  @body_component = nil
  @shelf_component = nil
  @preview_group = nil
  
  class << self
    
    # Main entry point - Show main dialog
    def start_workflow
      show_main_dialog
    end
    
    # Show the main dialog window
    def show_main_dialog
      dialog = UI::WebDialog.new(PLUGIN_NAME, false, PLUGIN_NAME, 400, 300, 100, 100)
      
      html_content = <<-HTML
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <style>
            body {
              font-family: Arial, sans-serif;
              background-color: #f5f5f5;
              padding: 20px;
              margin: 0;
            }
            
            .container {
              max-width: 400px;
              background: white;
              padding: 20px;
              border-radius: 8px;
              box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }
            
            h1 {
              color: #333;
              font-size: 18px;
              margin-top: 0;
              text-align: center;
            }
            
            .status {
              background-color: #e3f2fd;
              border-left: 4px solid #2196F3;
              padding: 10px;
              margin: 10px 0;
              border-radius: 4px;
              font-size: 12px;
              min-height: 40px;
            }
            
            .button-group {
              display: flex;
              flex-direction: column;
              gap: 10px;
              margin: 20px 0;
            }
            
            button {
              padding: 12px;
              font-size: 14px;
              border: none;
              border-radius: 4px;
              cursor: pointer;
              transition: all 0.3s ease;
              font-weight: bold;
            }
            
            .btn-select {
              background-color: #4CAF50;
              color: white;
            }
            
            .btn-select:hover {
              background-color: #45a049;
            }
            
            .btn-select:disabled {
              background-color: #cccccc;
              cursor: not-allowed;
            }
            
            .btn-preview {
              background-color: #2196F3;
              color: white;
            }
            
            .btn-preview:hover {
              background-color: #0b7dda;
            }
            
            .btn-preview:disabled {
              background-color: #cccccc;
              cursor: not-allowed;
            }
            
            .btn-apply {
              background-color: #FF9800;
              color: white;
              font-size: 16px;
            }
            
            .btn-apply:hover {
              background-color: #e68900;
            }
            
            .btn-apply:disabled {
              background-color: #cccccc;
              cursor: not-allowed;
            }
            
            .btn-cancel {
              background-color: #f44336;
              color: white;
            }
            
            .btn-cancel:hover {
              background-color: #da190b;
            }
            
            .status-text {
              color: #666;
              margin: 5px 0;
            }
            
            .step-number {
              color: #2196F3;
              font-weight: bold;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>#{PLUGIN_NAME}</h1>
            
            <div class="status">
              <div class="status-text"><span class="step-number">مرحله 1:</span> انتخاب بدنه کابینت</div>
              <div class="status-text" id="body-status">❌ بدنه انتخاب نشده</div>
            </div>
            
            <button class="btn-select" onclick="selectBody()">
              ✓ انتخاب بدنه (Base Part)
            </button>
            
            <hr style="margin: 15px 0; border: none; border-top: 1px solid #ddd;">
            
            <div class="status">
              <div class="status-text"><span class="step-number">مرحله 2:</span> انتخاب شلف</div>
              <div class="status-text" id="shelf-status">❌ شلف انتخاب نشده</div>
            </div>
            
            <button class="btn-select" onclick="selectShelf()">
              ✓ انتخاب شلف (Shelf)
            </button>
            
            <hr style="margin: 15px 0; border: none; border-top: 1px solid #ddd;">
            
            <div class="button-group">
              <button class="btn-preview" id="preview-btn" onclick="showPreview()" disabled>
                👁️ پیش‌نمایش
              </button>
              
              <button class="btn-apply" id="apply-btn" onclick="applyJoints()" disabled>
                ✓ اعمال فینجر جوینت
              </button>
              
              <button class="btn-cancel" onclick="closeDialog()">
                ✗ لغو
              </button>
            </div>
          </div>
          
          <script>
            function selectBody() {
              window.location = 'skp:select_body@';
            }
            
            function selectShelf() {
              window.location = 'skp:select_shelf@';
            }
            
            function showPreview() {
              window.location = 'skp:show_preview@';
            }
            
            function applyJoints() {
              window.location = 'skp:apply_joints@';
            }
            
            function closeDialog() {
              window.location = 'skp:close_dialog@';
            }
            
            function updateBodyStatus(status) {
              document.getElementById('body-status').innerHTML = status;
              updateButtonStates();
            }
            
            function updateShelfStatus(status) {
              document.getElementById('shelf-status').innerHTML = status;
              updateButtonStates();
            }
            
            function updateButtonStates() {
              var bodySelected = document.getElementById('body-status').innerHTML.includes('✓');
              var shelfSelected = document.getElementById('shelf-status').innerHTML.includes('✓');
              
              document.getElementById('preview-btn').disabled = !(bodySelected && shelfSelected);
              document.getElementById('apply-btn').disabled = !(bodySelected && shelfSelected);
            }
          </script>
        </body>
        </html>
      HTML
      
      dialog.set_on_close { close_dialog }
      dialog.add_action_callback("select_body") { |d, p| select_body_component(d) }
      dialog.add_action_callback("select_shelf") { |d, p| select_shelf_component(d) }
      dialog.add_action_callback("show_preview") { |d, p| show_preview_geometry(d) }
      dialog.add_action_callback("apply_joints") { |d, p| apply_joints_final(d) }
      dialog.add_action_callback("close_dialog") { |d, p| d.close }
      
      @current_dialog = dialog
      dialog.show
    end
    
    # Select body component
    def select_body_component(dialog)
      model = Sketchup.active_model
      selection = model.selection
      
      if selection.length == 0
        UI.messagebox("لطفاً یک کمپوننت انتخاب کنید!", MB_OK, PLUGIN_NAME)
        return
      end
      
      entity = selection[0]
      if !entity.is_a?(Sketchup::ComponentInstance)
        UI.messagebox("لطفاً یک کمپوننت انتخاب کنید، نه یک گروپ!", MB_OK, PLUGIN_NAME)
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
      
      status_text = "✓ بدنه انتخاب شد (#{dims[:length]}×#{dims[:width]}×#{dims[:height]} mm)"
      dialog.execute_script("updateBodyStatus('#{status_text}');")
    end
    
    # Select shelf component
    def select_shelf_component(dialog)
      model = Sketchup.active_model
      selection = model.selection
      
      if selection.length == 0
        UI.messagebox("لطفاً یک کمپوننت انتخاب کنید!", MB_OK, PLUGIN_NAME)
        return
      end
      
      entity = selection[0]
      if !entity.is_a?(Sketchup::ComponentInstance)
        UI.messagebox("لطفاً یک کمپوننت انتخاب کنید، نه یک گروپ!", MB_OK, PLUGIN_NAME)
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
      
      status_text = "✓ شلف انتخاب شد (#{dims[:length]}×#{dims[:width]}×#{dims[:height]} mm)"
      dialog.execute_script("updateShelfStatus('#{status_text}');")
    end
    
    # Show preview
    def show_preview_geometry(dialog)
      if @body_component.nil? || @shelf_component.nil?
        UI.messagebox("لطفاً هردو کمپوننت را انتخاب کنید!", MB_OK, PLUGIN_NAME)
        return
      end
      
      model = Sketchup.active_model
      
      # Remove old preview if exists
      if @preview_group
        model.active_entities.erase_entities(@preview_group)
      end
      
      # Create new preview
      @preview_group = model.active_entities.add_group
      @preview_group.name = "Finger Joint Preview"
      
      begin
        create_preview_fingers(@preview_group, @shelf_component, @body_component, model)
        UI.messagebox("پیش‌نمایش نمایش داده شد. اگر درست است، 'اعمال' را کلیک کنید.", MB_OK, PLUGIN_NAME)
      rescue => error
        model.active_entities.erase_entities(@preview_group)
        @preview_group = nil
        UI.messagebox("خطا: #{error.message}", MB_OK, PLUGIN_NAME)
      end
    end
    
    # Apply finger joints
    def apply_joints_final(dialog)
      if @body_component.nil? || @shelf_component.nil?
        UI.messagebox("لطفاً هردو کمپوننت را انتخاب کنید!", MB_OK, PLUGIN_NAME)
        return
      end
      
      model = Sketchup.active_model
      
      # Remove preview
      if @preview_group
        model.active_entities.erase_entities(@preview_group)
        @preview_group = nil
      end
      
      model.start_operation("Apply Finger Joints", true)
      
      begin
        create_fingers_on_shelf(@shelf_component, model)
        create_pockets_on_body(@body_component, @shelf_component, model)
        model.commit_operation
        
        UI.messagebox("فینجر جوینت‌ها با موفقیت اعمال شدند! ✓", MB_OK, PLUGIN_NAME)
        dialog.close
        
      rescue => error
        model.abort_operation
        UI.messagebox("خطا: #{error.message}", MB_OK, PLUGIN_NAME)
      end
    end
    
    def close_dialog
      @body_component = nil
      @shelf_component = nil
      if @preview_group
        Sketchup.active_model.active_entities.erase_entities(@preview_group)
        @preview_group = nil
      end
    end
    
    private
    
    def create_preview_fingers(preview_group, shelf_component, body_component, model)
      preview_entities = preview_group.entities
      shelf_bounds = shelf_component.bounds
      
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
        "Front Finger"
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
        "Back Finger"
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
  
  # Add menu items
  unless file_loaded?(__FILE__)
    menu = UI.menu("Plugins")
    menu.add_item("Cabinet Finger Joint") do
      CabinetFingerJoint.start_workflow
    end
    file_loaded(__FILE__)
  end
end

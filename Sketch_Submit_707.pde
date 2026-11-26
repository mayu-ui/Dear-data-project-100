Table table;
BugRecord[] bugs;

void setup() {
  size(1100, 620);
  smooth();
  
  // Load the CSV from the 'data' folder
  table = loadTable("debugging_data.csv", "header");
  
  if (table == null) {
    println("ERROR: Could not find debugging_data.csv inside the sketch's 'data' folder.");
    noLoop();
    return;
  }
  
  // Initialize the array to hold all 50 rows
  bugs = new BugRecord[table.getRowCount()];
  
  // Parse each row into a BugRecord object
  for (int i = 0; i < table.getRowCount(); i++) {
    TableRow row = table.getRow(i);
    
    int id = row.getInt("id");
    String date = row.getString("date");
    String timeOfDay = row.getString("timeOfDay");
    String category = row.getString("errorCategory");
    int fixMinutes = row.getInt("fixMinutes");
    int frustration = row.getInt("frustration");
    String resolution = row.getString("resolution");
    
    bugs[i] = new BugRecord(id, date, timeOfDay, category, fixMinutes, frustration, resolution);
  }
}

void draw() {
  background(24, 26, 32); // Dark slate background
  
  if (bugs == null) return;
  
  drawHeader();
  drawLegend();
  
  BugRecord hoveredBug = null;
  
  // 10 columns x 5 rows for your 50 entries
  int cols = 10;
  float startX = 110;
  float startY = 180;
  float spacingX = 96;
  float spacingY = 82;
  
  for (int i = 0; i < bugs.length; i++) {
    int col = i % cols;
    int row = i / cols;
    
    float x = startX + col * spacingX;
    float y = startY + row * spacingY;
    
    bugs[i].display(x, y);
    
    // Check if mouse is hovering over this glyph
    if (bugs[i].isHovered(mouseX, mouseY, x, y)) {
      hoveredBug = bugs[i];
    }
  }
  
  // Draw interactive tooltip if hovering over a bug
  if (hoveredBug != null) {
    drawTooltip(hoveredBug);
  }
}

void drawHeader() {
  fill(245);
  textAlign(LEFT, TOP);
  textSize(22);
  text("Dear Data: Debugging & Frustration Log (n = 50)", 40, 25);
  
  fill(170);
  textSize(13);
  text("Size = Fix Duration (1–35 mins)  |  Border = Frustration (1–5)  |  Inner Mark = Resolution  |  Hover any glyph for details", 40, 56);
}

void drawLegend() {
  String[] categories = {"Syntax", "Scope", "Type", "Visual", "Logic", "Null"};
  float startX = 40;
  float y = 98;
  
  textSize(12);
  textAlign(LEFT, CENTER);
  
  for (int i = 0; i < categories.length; i++) {
    fill(getCategoryColor(categories[i]));
    noStroke();
    circle(startX + i * 115, y, 14);
    
    fill(220);
    text(categories[i], startX + i * 115 + 14, y);
  }
  
  // Resolution symbol guide on the right side of the legend
  fill(170);
  text("Inner Mark:   ● Self    ○ RubberDuck    ■ Docs / Console / Peer", 735, y);
}

void drawTooltip(BugRecord b) {
  float boxW = 365;
  float boxH = 102;
  float bx = constrain(mouseX + 15, 20, width - boxW - 20);
  float by = constrain(mouseY + 15, 20, height - boxH - 20);
  
  fill(15, 17, 22, 240);
  stroke(getCategoryColor(b.category));
  strokeWeight(2);
  rect(bx, by, boxW, boxH, 8);
  
  fill(255);
  noStroke();
  textAlign(LEFT, TOP);
  textSize(13);
  text("Bug #" + b.id + "  (" + b.date + " • " + b.timeOfDay + ")", bx + 14, by + 12);
  
  fill(200);
  textSize(12);
  text("Category: " + b.category + "   |   Resolution: " + b.resolution, bx + 14, by + 38);
  text("Time to Fix: " + b.fixMinutes + " mins   |   Frustration: " + b.frustration + "/5", bx + 14, by + 62);
}

color getCategoryColor(String cat) {
  if (cat.equals("Syntax")) return color(86, 180, 233);   // Sky Blue
  if (cat.equals("Scope"))  return color(230, 159, 0);    // Orange
  if (cat.equals("Type"))   return color(0, 158, 115);    // Teal Green
  if (cat.equals("Visual")) return color(204, 121, 167);  // Pink/Purple
  if (cat.equals("Logic"))  return color(213, 94, 0);     // Vermilion Red
  if (cat.equals("Null"))   return color(240, 228, 66);   // Yellow
  return color(180);
}

class BugRecord {
  int id;
  String date;
  String timeOfDay;
  String category;
  int fixMinutes;
  int frustration;
  String resolution;
  
  BugRecord(int id, String date, String timeOfDay, String category, int fixMinutes, int frustration, String resolution) {
    this.id = id;
    this.date = date;
    this.timeOfDay = timeOfDay;
    this.category = category;
    this.fixMinutes = fixMinutes;
    this.frustration = frustration;
    this.resolution = resolution;
  }
  
  void display(float x, float y) {
    // Scale fixMinutes (1 to 35 mins) to circle diameter (16 to 52 px)
    float diameter = constrain(map(fixMinutes, 1, 35, 16, 52), 16, 52);
    
    // Outer ring thickness represents frustration (1 to 5)
    stroke(255, 220);
    strokeWeight(frustration * 0.95);
    fill(getCategoryColor(category));
    circle(x, y, diameter);
    
    // Inner glyph mark represents resolution method
    noStroke();
    fill(24, 26, 32);
    if (resolution.equals("RubberDuck")) {
      noFill();
      stroke(24, 26, 32);
      strokeWeight(2);
      circle(x, y, diameter * 0.42);
    } else if (resolution.equals("Self")) {
      circle(x, y, 5.5);
    } else {
      rectMode(CENTER);
      rect(x, y, 5.5, 5.5);
      rectMode(CORNER);
    }
  }
  
  boolean isHovered(float mx, float my, float x, float y) {
    float diameter = constrain(map(fixMinutes, 1, 35, 16, 52), 16, 52);
    return dist(mx, my, x, y) < (diameter / 2.0) + 4;
  }
}

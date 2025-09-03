#!/usr/bin/env python3
"""
Generate app icons for Family Health app from SVG source
"""

import os
from PIL import Image, ImageDraw
import io

def create_family_health_icon(size):
    """Create a family health themed icon at the specified size"""
    # Create image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Calculate scaling factor
    scale = size / 1024.0
    
    # Background gradient (simplified to solid color)
    bg_color = (74, 144, 226, 255)  # Blue
    draw.ellipse([0, 0, size, size], fill=bg_color)
    
    # Family silhouettes
    white = (255, 255, 255, 230)
    
    # Parent 1 (left)
    parent1_x = int(300 * scale)
    parent1_y = int(400 * scale)
    parent1_radius = int(60 * scale)
    draw.ellipse([parent1_x - parent1_radius, parent1_y - parent1_radius, 
                  parent1_x + parent1_radius, parent1_y + parent1_radius], fill=white)
    
    # Parent 1 body
    parent1_body_x = int(270 * scale)
    parent1_body_y = int(460 * scale)
    parent1_body_w = int(60 * scale)
    parent1_body_h = int(120 * scale)
    draw.rounded_rectangle([parent1_body_x, parent1_body_y, 
                           parent1_body_x + parent1_body_w, parent1_body_y + parent1_body_h], 
                          radius=int(30 * scale), fill=white)
    
    # Parent 2 (right)
    parent2_x = int(724 * scale)
    parent2_y = int(400 * scale)
    parent2_radius = int(60 * scale)
    draw.ellipse([parent2_x - parent2_radius, parent2_y - parent2_radius, 
                  parent2_x + parent2_radius, parent2_y + parent2_radius], fill=white)
    
    # Parent 2 body
    parent2_body_x = int(694 * scale)
    parent2_body_y = int(460 * scale)
    parent2_body_w = int(60 * scale)
    parent2_body_h = int(120 * scale)
    draw.rounded_rectangle([parent2_body_x, parent2_body_y, 
                           parent2_body_x + parent2_body_w, parent2_body_y + parent2_body_h], 
                          radius=int(30 * scale), fill=white)
    
    # Child 1 (center-left)
    child1_x = int(400 * scale)
    child1_y = int(500 * scale)
    child1_radius = int(40 * scale)
    draw.ellipse([child1_x - child1_radius, child1_y - child1_radius, 
                  child1_x + child1_radius, child1_y + child1_radius], fill=white)
    
    # Child 1 body
    child1_body_x = int(380 * scale)
    child1_body_y = int(540 * scale)
    child1_body_w = int(40 * scale)
    child1_body_h = int(80 * scale)
    draw.rounded_rectangle([child1_body_x, child1_body_y, 
                           child1_body_x + child1_body_w, child1_body_y + child1_body_h], 
                          radius=int(20 * scale), fill=white)
    
    # Child 2 (center-right)
    child2_x = int(624 * scale)
    child2_y = int(500 * scale)
    child2_radius = int(40 * scale)
    draw.ellipse([child2_x - child2_radius, child2_y - child2_radius, 
                  child2_x + child2_radius, child2_y + child2_radius], fill=white)
    
    # Child 2 body
    child2_body_x = int(604 * scale)
    child2_body_y = int(540 * scale)
    child2_body_w = int(40 * scale)
    child2_body_h = int(80 * scale)
    draw.rounded_rectangle([child2_body_x, child2_body_y, 
                           child2_body_x + child2_body_w, child2_body_y + child2_body_h], 
                          radius=int(20 * scale), fill=white)
    
    # Heart symbol in center
    heart_color = (255, 107, 107, 255)  # Red
    heart_x = int(512 * scale)
    heart_y = int(650 * scale)
    heart_size = int(60 * scale)
    
    # Simple heart shape
    heart_left = heart_x - heart_size
    heart_right = heart_x + heart_size
    heart_top = heart_y - heart_size
    heart_bottom = heart_y + heart_size
    
    # Draw heart (simplified as two circles and triangle)
    draw.ellipse([heart_left, heart_top, heart_x, heart_y], fill=heart_color)
    draw.ellipse([heart_x, heart_top, heart_right, heart_y], fill=heart_color)
    draw.polygon([heart_x, heart_y, heart_left, heart_bottom, heart_right, heart_bottom], fill=heart_color)
    
    # Health cross in heart
    cross_color = (255, 255, 255, 230)
    cross_x = int(500 * scale)
    cross_y = int(520 * scale)
    cross_w = int(24 * scale)
    cross_h = int(80 * scale)
    cross_h_w = int(64 * scale)
    cross_h_h = int(24 * scale)
    
    # Vertical line
    draw.rectangle([cross_x, cross_y, cross_x + cross_w, cross_y + cross_h], fill=cross_color)
    # Horizontal line
    draw.rectangle([cross_x - int(20 * scale), cross_y + int(20 * scale), 
                   cross_x + cross_h_w - int(20 * scale), cross_y + int(20 * scale) + cross_h_h], fill=cross_color)
    
    return img

def main():
    """Generate all required icon sizes"""
    icon_sizes = [
        (20, "icon_20.png"),
        (29, "icon_29.png"), 
        (40, "icon_40.png"),
        (60, "icon_60.png"),
        (76, "icon_76.png"),
        (83.5, "icon_83.5.png"),
        (120, "icon_120.png"),
        (152, "icon_152.png"),
        (167, "icon_167.png"),
        (1024, "icon_1024.png")
    ]
    
    output_dir = "RecipeApp/Assets.xcassets/AppIcon.appiconset"
    
    for size, filename in icon_sizes:
        print(f"Generating {filename} ({size}x{size})")
        icon = create_family_health_icon(int(size))
        icon.save(os.path.join(output_dir, filename), "PNG")
    
    print("All icons generated successfully!")

if __name__ == "__main__":
    main()

from PIL import Image, ImageDraw
import numpy as np
import os

def extract_contiguous_shapes(image_path, output_dir, threshold=200):
    """
    Extracts contiguous shapes from an image and saves them as individual tiles.

    :param image_path: Path to the input image (e.g., "tile_chart.png").
    :param output_dir: Directory to save the individual tile images.
    :param threshold: Grayscale threshold for shape detection (default=200).
    """
    # Load the input image
    img = Image.open(image_path).convert("L")  # Convert to grayscale
    img_array = np.array(img)

    # Threshold the image to binary (1 for shapes, 0 for whitespace)
    binary_image = (img_array < threshold).astype(np.uint8)

    # Create the output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)

    # Label contiguous regions
    visited = np.zeros_like(binary_image)
    shapes = []
    rows, cols = binary_image.shape

    def flood_fill_iterative(start_r, start_c):
        """Iteratively find all pixels in a contiguous shape."""
        stack = [(start_r, start_c)]
        shape_pixels = []
        while stack:
            r, c = stack.pop()
            if 0 <= r < rows and 0 <= c < cols and not visited[r, c] and binary_image[r, c] == 1:
                visited[r, c] = 1
                shape_pixels.append((r, c))
                stack.extend([(r + 1, c), (r - 1, c), (r, c + 1), (r, c - 1)])
        return shape_pixels

    # Find all contiguous shapes
    for r in range(rows):
        for c in range(cols):
            if binary_image[r, c] == 1 and not visited[r, c]:
                shape_pixels = flood_fill_iterative(r, c)
                shapes.append(shape_pixels)

    # Extract each shape and save as an image
    for i, shape_pixels in enumerate(shapes):
        # Determine bounding box
        min_r = min(p[0] for p in shape_pixels)
        max_r = max(p[0] for p in shape_pixels)
        min_c = min(p[1] for p in shape_pixels)
        max_c = max(p[1] for p in shape_pixels)

        # Create a blank image with transparency for the shape
        shape_img = Image.new("RGBA", (max_c - min_c + 1, max_r - min_r + 1), (0, 0, 0, 0))
        draw = ImageDraw.Draw(shape_img)
        for r, c in shape_pixels:
            draw.point((c - min_c, r - min_r), fill=(0, 0, 0, 255))  # Black shape with full opacity

        # Save the shape
        shape_img.save(f"{output_dir}/tile_{i}.png")

    print(f"Extracted {len(shapes)} shapes to {output_dir}")

# Example usage
extract_contiguous_shapes("Figure_1.png", "output_tiles")

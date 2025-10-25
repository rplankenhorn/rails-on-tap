# Picture Features Documentation

## Overview

Rails on Tap now includes comprehensive picture functionality for capturing and sharing moments from your kegerator system.

## Features

### 1. User Profile Pictures

Users can upload profile pictures (mugshots) that appear throughout the application.

**How to upload:**
1. Navigate to your profile (click "Profile" in the top menu)
2. Scroll to the "Profile Picture" section
3. Click "Choose File" and select an image
4. Click "Update Profile" to save

**Where profile pictures appear:**
- User profile pages
- Drink detail pages (next to the drinker's name)
- Throughout the app where users are mentioned

### 2. Drink Pour Pictures

Take pictures during or after pouring a drink to capture the moment.

**How to add pictures to drinks:**
1. **During/After a Pour:** Navigate to the drink detail page
2. Click the "📸 Add Picture" button
3. Upload your image and add an optional caption
4. The picture will be automatically linked to that drink

**Quick Upload:**
- From any drink page: Click "📸 Add Picture"
- From the Pictures page: Click "📸 Upload Picture" and optionally select a drink

### 3. Picture Gallery

View all pictures in a beautiful grid layout.

**Access the gallery:**
- Click "📸 Pictures" in the main navigation
- Browse all pictures uploaded to the system
- Click any picture to view full details

**Picture details include:**
- Full-size image
- Caption (if provided)
- Photographer
- Associated drink, keg, or session
- Timestamp

### 4. Picture Management

**Uploading:**
- Accepted formats: JPG, PNG, GIF, WebP
- Images are automatically processed and optimized
- Variants are created for thumbnails and displays

**Captions:**
- Optional text description
- Auto-generated if not provided (e.g., "Username pouring drink #123")

**Deletion:**
- Picture owners and admins can delete pictures
- Navigate to picture detail page and click "Delete"

## Technical Details

### Models

**Picture Model:**
- `image`: ActiveStorage attachment
- `caption`: Optional text description
- `time`: Timestamp when picture was taken
- `user_id`: Photographer (optional)
- `drink_id`: Associated drink (optional)
- `keg_id`: Associated keg (optional)
- `drinking_session_id`: Associated session (optional)

**User Model:**
- `mugshot_image`: ActiveStorage attachment for profile picture

### Storage

Pictures are stored using Rails ActiveStorage:
- Development: Local disk storage (`storage/`)
- Production: Configure cloud storage (S3, GCS, Azure) in `config/storage.yml`

### Image Variants

Images are automatically processed into variants:
- Thumbnails: 200x200px
- Medium: 400x400px
- Large: 600x600px
- Profile pictures: 300x300px circular

## API Endpoints

### Pictures Resource

- `GET /pictures` - List all pictures
- `GET /pictures/:id` - Show picture details
- `GET /pictures/new` - New picture form
- `POST /pictures` - Create picture
- `DELETE /pictures/:id` - Delete picture

### Query Parameters

- `GET /pictures/new?drink_id=:id` - Create picture for specific drink

## Best Practices

### For Great Pour Pictures

1. **Lighting:** Use good lighting to show off the beer's color
2. **Angle:** Capture the pour at an interesting angle
3. **Context:** Include the tap or keg in the frame
4. **Timing:** Take the picture when the glass has a nice head
5. **Caption:** Add a fun or descriptive caption

### For Profile Pictures

1. **Clear:** Use a clear, well-lit photo
2. **Appropriate:** Keep it work-safe and appropriate
3. **Format:** Square images work best (they're cropped to circles)
4. **Size:** Reasonable file size (< 5MB recommended)

## Future Enhancements

Potential features to add:

- [ ] Camera integration for live capture
- [ ] Automatic picture capture during pours (hardware integration)
- [ ] Picture filters and editing
- [ ] Social features (likes, comments)
- [ ] Picture albums/collections
- [ ] Slideshow mode
- [ ] Export/sharing to social media
- [ ] QR code picture download
- [ ] Facial recognition for auto-tagging

## Troubleshooting

### Image Upload Fails

- Check file size (default limit: 5MB)
- Verify file format is supported
- Ensure storage is properly configured
- Check disk space in development
- Review logs for detailed error messages

### Images Not Displaying

- Run `rails active_storage:install` if migrations are missing
- Verify ActiveStorage tables exist in database
- Check that images were actually uploaded (check storage folder)
- Review CSP headers if images are blocked

### Performance Issues

- Consider cloud storage for production
- Implement CDN for faster image delivery
- Use image optimization gems (e.g., `image_processing`)
- Add lazy loading for image galleries
- Implement pagination for large galleries

## Configuration

### Storage Backends

Edit `config/storage.yml` to configure storage:

```yaml
# Local storage (development)
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>

# Amazon S3 (production)
amazon:
  service: S3
  access_key_id: <%= ENV['AWS_ACCESS_KEY_ID'] %>
  secret_access_key: <%= ENV['AWS_SECRET_ACCESS_KEY'] %>
  region: us-east-1
  bucket: your-bucket-name
```

Set in `config/environments/production.rb`:
```ruby
config.active_storage.service = :amazon
```

### Image Processing

Requires ImageMagick or libvips:

```bash
# macOS
brew install imagemagick
# or
brew install vips

# Ubuntu
sudo apt-get install imagemagick
# or
sudo apt-get install libvips
```

## Security

### Upload Validation

- File type checking via content_type validation
- File size limits enforced
- Malicious file detection
- User authentication required for uploads

### Access Control

- Pictures are publicly viewable once uploaded
- Only authenticated users can upload
- Users can delete their own pictures
- Admins can delete any picture

### Storage Security

- Private S3 buckets with signed URLs (recommended for production)
- Content security policies to prevent XSS
- Secure HTTPS delivery
- Regular backup of storage

## Related Documentation

- [Active Storage Overview](https://guides.rubyonrails.org/active_storage_overview.html)
- [Image Processing with Rails](https://edgeguides.rubyonrails.org/active_storage_overview.html#transforming-images)
- [Kegbot Hardware Integration](MQTT_INTEGRATION.md)

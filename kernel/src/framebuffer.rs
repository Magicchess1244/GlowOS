use bootloader_api::{BootInfo, info::{FrameBufferInfo, PixelFormat}};

pub mod text_renderer;
pub mod text_font;

struct FrameBuffer {
    info: FrameBufferInfo,
    buffer: &'static mut [u8],
}

struct Color {
    r: u8,
    g: u8,
    b: u8,
}

impl FrameBuffer {
    pub fn new(boot_info: &'static mut BootInfo) -> Self{
        let fb = boot_info.framebuffer.as_mut().unwrap();
        let info = fb.info();
        let buffer = fb.buffer_mut();

        Self {
            info: info,
            buffer: buffer,
        }
    }

    pub fn put_pixel(&mut self ,x: usize, y: usize, color: Color) {
        let offset = (x + y * self.info.stride) * self.info.bytes_per_pixel;
        match self.info.pixel_format {
            PixelFormat::Rgb => {
                self.buffer[offset]     = color.r;
                self.buffer[offset + 1] = color.g;
                self.buffer[offset + 2] = color.b;
            },
            PixelFormat::Bgr => {
                self.buffer[offset]     = color.b;
                self.buffer[offset + 1] = color.g;
                self.buffer[offset + 2] = color.r;
            },
            _ => {}
        }
    }
}
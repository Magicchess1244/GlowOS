use bootloader_api::info::{FrameBufferInfo, PixelFormat, FrameBuffer};
use text_renderer::FontRenderer;

pub mod text_renderer;
pub mod text_font;

pub static mut RENDERER: Option<Rernderer> = None; 

pub struct Rernderer {
    info: FrameBufferInfo,
    buffer: &'static mut [u8],
    background_color: Color,
    font_renderer: FontRenderer,
}

#[derive(Clone, Copy)]
pub struct Color {
    r: u8,
    g: u8,
    b: u8,
}

impl Color {
    pub fn new(r: u8, g: u8, b: u8) -> Self {
        Color { r, g, b }
    }
}

impl Rernderer {
    pub fn new(framebuffer: &'static mut FrameBuffer, background_color: Color) -> Self{
        let fb = framebuffer;
        let info = fb.info();
        let buffer = fb.buffer_mut();
        let font_renderer = FontRenderer::new(info.width, info.height);

        Self {
            info: info,
            buffer: buffer,
            background_color: background_color,
            font_renderer: font_renderer,
        }
    }

    pub fn put_pixel(&mut self ,x: usize, y: usize, color: Color) {
        if x >= self.info.width || y >= self.info.height {
            return;
        }

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

    pub fn clear_screen(&mut self){
        for x in 0..self.info.width {
            for y in 0..self.info.height {
                self.put_pixel(x, y, self.background_color.clone());
            }
        }
    }
}

pub fn init(framebuffer: &'static mut FrameBuffer){
    let bg_color = Color::new(0,0,0);

    unsafe {RENDERER = Some(Rernderer::new(framebuffer, bg_color))}; 

    #[allow(static_mut_refs)]
    let renderer = unsafe{RENDERER.as_mut().unwrap()};
    renderer.clear_screen();
    renderer.font_renderer.test();
    renderer.font_renderer.draw_buffer();
}
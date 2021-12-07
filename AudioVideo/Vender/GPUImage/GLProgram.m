//  This is Jeff LaMarche's GLProgram OpenGL shader wrapper class from his OpenGL ES 2.0 book.
//  A description of this can be found at his page on the topic:
//  http://iphonedevelopment.blogspot.com/2010/11/opengl-es-20-for-ios-chapter-4.html


#import "GLProgram.h"
// START:typedefs
#pragma mark Function Pointer Definitions
typedef void (*GLInfoFunction)(GLuint program, GLenum pname, GLint* params);
typedef void (*GLLogFunction) (GLuint program, GLsizei bufsize, GLsizei* length, GLchar* infolog);
// END:typedefs
#pragma mark -
#pragma mark Private Extension Method Declaration
// START:extension
@interface GLProgram()

- (BOOL)compileShader:(GLuint *)shader 
                 type:(GLenum)type 
               string:(NSString *)shaderString;
@end
// END:extension
#pragma mark -

@implementation GLProgram
// START:init

@synthesize initialized = _initialized;

- (id)initWithVertexShaderString:(NSString *)vShaderString 
            fragmentShaderString:(NSString *)fShaderString;
{
    if ((self = [super init])) 
    {
        _initialized = NO;
        
        attributes = [[NSMutableArray alloc] init];
        uniforms = [[NSMutableArray alloc] init];
        // 创建空的着色器程序对象
        program = glCreateProgram();
        
        // 创建&编译顶点shader
        if (![self compileShader:&vertShader 
                            type:GL_VERTEX_SHADER 
                          string:vShaderString])
        {
            NSLog(@"Failed to compile vertex shader");
        }
        
        // Create and compile fragment shader
        // 创建&编译片元shader
        if (![self compileShader:&fragShader 
                            type:GL_FRAGMENT_SHADER 
                          string:fShaderString])
        {
            NSLog(@"Failed to compile fragment shader");
        }
        // 附加着色器到着色器程序对象
        glAttachShader(program, vertShader);
        glAttachShader(program, fragShader);
    }
    
    return self;
}

- (id)initWithVertexShaderString:(NSString *)vShaderString 
          fragmentShaderFilename:(NSString *)fShaderFilename;
{
    NSString *fragShaderPathname = [[NSBundle mainBundle] pathForResource:fShaderFilename ofType:@"fsh"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:fragShaderPathname encoding:NSUTF8StringEncoding error:nil];
    
    if ((self = [self initWithVertexShaderString:vShaderString fragmentShaderString:fragmentShaderString])) 
    {
    }
    
    return self;
}

- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename 
            fragmentShaderFilename:(NSString *)fShaderFilename;
{
    NSString *vertShaderPathname = [[NSBundle mainBundle] pathForResource:vShaderFilename ofType:@"vsh"];
    NSString *vertexShaderString = [NSString stringWithContentsOfFile:vertShaderPathname encoding:NSUTF8StringEncoding error:nil];

    NSString *fragShaderPathname = [[NSBundle mainBundle] pathForResource:fShaderFilename ofType:@"fsh"];
    NSString *fragmentShaderString = [NSString stringWithContentsOfFile:fragShaderPathname encoding:NSUTF8StringEncoding error:nil];
    
    if ((self = [self initWithVertexShaderString:vertexShaderString fragmentShaderString:fragmentShaderString])) 
    {
    }
    
    return self;
}
// END:init
// START:compile
- (BOOL)compileShader:(GLuint *)shader 
                 type:(GLenum)type 
               string:(NSString *)shaderString
{
//    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();

    GLint status;
    const GLchar *source;
    
    source = 
      (GLchar *)[shaderString UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    /*
     创建一个空的着色器对象,支持两种类型的着色器。
     GL_VERTEX_SHADER类型的着色器是一个用于在可编程顶点处理器上运行的着色器。
     GL_FRAGMENT_SHADER类型的着色器是一个着色器，旨在在可编程片段处理器上运行
     */
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    /*
     检验着色器编译是否成功
     参数
     shader
     指定要查询的着色器对象，直接放入需要检查的着色器即可。
     pname
     指定着色器对象的参数。 可接受的符号名称为
     (1)GL_SHADER_TYPE：
     shader_type:着色器类型
     用来判断并返回着色器类型，若是顶点着色器返回GL_VERTEX_SHADER，若为片元着色器返回GL_FRAGMENT_SHADER
     (2)GL_DELETE_STATUS:
     detele status：删除状态
     判断着色器是否被删除，是返回GL_TRUE,否则返回GL_FALSE,
     (3)GL_COMPILE_STATUS:
     compile_status:编译状态
     用于检测编译是否成功，成功为GL_TRUE，否则为GL_FALSE.
     (4)GL_INFO_LOG_LENGTH:
     information log length： log是日志的意思，所以是返回着色器的信息日志的长度
     用于返回着色器的信息日志的长度，包括空终止字符（即存储信息日志所需的字符缓冲区的大小）。 如果着色器没有信息日志，则返回值0。
     (5)GL_SHADER_SOURCE_LENGTH:
     SHADER_SOURCE_LENGTH:着色器源码长度
     返回着色器源码长度，不存在则返回0；
     
     params
     函数将返回的结果存储在输入的第三个参数中，因为这个函数得到的结果有很多种，所以要单独放在第三个参数当中，所以是void glGetShaderiv而不是GLuint。
     错误
     GL_INVALID_ENUM： pname不是一个可接受的值。
     GL_INVALID_VALUE： shader不是OpenGL生成的值。
     GL_INVALID_OPERATION： 不支持着色器编译器的情况下查询pname为GL_COMPILE_STATUS，GL_INFO_LOG_LENGTH或GL_SHADER_SOURCE_LENGTH（GL_SHADER_TYPE，GL_DELETE_STATUS不会报这个错）。
     GL_INVALID_OPERATION： shader没有关联着色器对象。
     */
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);

	if (status != GL_TRUE)
	{
		GLint logLength;
		glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
		if (logLength > 0)
		{
			GLchar *log = (GLchar *)malloc(logLength);
			glGetShaderInfoLog(*shader, logLength, &logLength, log);
            if (shader == &vertShader)
            {
                self.vertexShaderLog = [NSString stringWithFormat:@"%s", log];
            }
            else
            {
                self.fragmentShaderLog = [NSString stringWithFormat:@"%s", log];
            }

			free(log);
		}
	}	
	
//    CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
//    NSLog(@"Compiled in %f ms", linkTime * 1000.0);

    return status == GL_TRUE;
}
// END:compile
#pragma mark -
// START:addattribute
- (void)addAttribute:(NSString *)attributeName
{
    if (![attributes containsObject:attributeName])
    {
        [attributes addObject:attributeName];
        /*
         将通用顶点属性索引与命名属性变量相关联
         参数
         program
         指定要在其中建立关联的程序对象的句柄。
         index
         指定要绑定的通用顶点属性的索引。
         name
         指定一个以空终止符结尾的字符串，其中包含要绑定索引的顶点着色器属性变量的名称
         https://blog.csdn.net/flycatdeng/article/details/82664058
         */
        glBindAttribLocation(program, 
                             (GLuint)[attributes indexOfObject:attributeName],
                             [attributeName UTF8String]);
    }
}
// END:addattribute
// START:indexmethods
- (GLuint)attributeIndex:(NSString *)attributeName
{
    return (GLuint)[attributes indexOfObject:attributeName];
}
- (GLuint)uniformIndex:(NSString *)uniformName
{
    return glGetUniformLocation(program, [uniformName UTF8String]);
}
// END:indexmethods
#pragma mark -
// START:link
- (BOOL)link
{
//    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();

    GLint status;
    
    glLinkProgram(program);
    // glGetProgramiv以params形式返回指定的program对象的参数值
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if (status == GL_FALSE)
        return NO;
    // 附着着色器对象以及分离或删除着色器对象,这些操作都不会影响属于当前状态的可执行文件
    if (vertShader)
    {
        // 删除指定的着色器对象
        glDeleteShader(vertShader);
        vertShader = 0;
    }
    if (fragShader)
    {
        glDeleteShader(fragShader);
        fragShader = 0;
    }
    
    self.initialized = YES;

//    CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
//    NSLog(@"Linked in %f ms", linkTime * 1000.0);

    return YES;
}
// END:link
// START:use
- (void)use
{
    // 使用程序对象作为当前渲染状态的一部分
    glUseProgram(program);
}
// END:use
#pragma mark -

- (void)validate;
{
	GLint logLength;
	
	glValidateProgram(program);
	glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0)
	{
		GLchar *log = (GLchar *)malloc(logLength);
		glGetProgramInfoLog(program, logLength, &logLength, log);
        self.programLog = [NSString stringWithFormat:@"%s", log];
		free(log);
	}	
}

#pragma mark -
// START:dealloc
- (void)dealloc
{
    if (vertShader)
        glDeleteShader(vertShader);
        
    if (fragShader)
        glDeleteShader(fragShader);
    
    if (program)
        glDeleteProgram(program);
       
}
// END:dealloc
@end

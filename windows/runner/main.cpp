#include <flutter/dart_project.h>            // 引入 Flutter Dart 项目的头文件
#include <flutter/flutter_view_controller.h> // 引入 Flutter 视图控制器的头文件
#include <windows.h>                         // 引入 Windows API 的头文件

#include "flutter_window.h" // 引入自定义的 Flutter 窗口类头文件
#include "utils.h"          // 引入自定义的工具函数头文件

// Windows 应用程序的入口点
int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command)
{
    // 当存在控制台时（例如通过 'flutter run'），将当前应用程序附加到父进程的控制台；
    // 如果没有附加且正在调试，则创建一个新的控制台并附加。
    if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent())
    {
        CreateAndAttachConsole(); // 创建并附加控制台
    }

    // 初始化 COM，以便库和插件可以使用
    ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

    // 创建一个 Dart 项目实例，指定资源目录为 "data"
    flutter::DartProject project(L"data");

    // 获取命令行参数并存储在向量中
    std::vector<std::string> command_line_arguments = GetCommandLineArguments();

    // 将命令行参数设置到 Dart 项目的入口点
    project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

    // 创建 Flutter 窗口实例
    FlutterWindow window(project);
    // 设置窗口的初始大小为 1280x720
    Win32Window::Size size(1280, 720);

    RECT rc; // 矩形结构体，用于存储工作区的边界
    // 获取工作区的矩形区域
    SystemParametersInfo(SPI_GETWORKAREA, 0, &rc, 0);

    // 计算窗口的中心位置
    int xPos = (rc.right - rc.left) / 2 - size.width + rc.left; // 水平居中
    int yPos = (rc.bottom - rc.top) / 2 - size.height + rc.top; // 垂直居中
    Win32Window::Point origin(xPos, yPos);                      // 设置窗口的起始位置

    // 创建窗口，标题为 "认知协同康复训练及评估系统"
    if (!window.Create(L"认知协同康复训练及评估系统", origin, size))
    {
        return EXIT_FAILURE; // 如果创建失败，则返回失败状态
    }

    // 设置窗口关闭时退出应用程序
    window.SetQuitOnClose(true);
#ifdef NDEBUG
    // 获取窗口句柄
    HWND hwnd = window.GetHandle();
    // 禁用窗口的大小调整功能，移除可调整大小的边框
    SetWindowLong(hwnd, GWL_STYLE, GetWindowLong(hwnd, GWL_STYLE) & ~WS_THICKFRAME);
#endif

    // 消息循环，处理窗口消息
    ::MSG msg;
    while (::GetMessage(&msg, nullptr, 0, 0))
    {
        ::TranslateMessage(&msg);
        ::DispatchMessage(&msg);
    }

    // 反初始化 COM 库
    ::CoUninitialize();
    return EXIT_SUCCESS; // 返回成功状态
}

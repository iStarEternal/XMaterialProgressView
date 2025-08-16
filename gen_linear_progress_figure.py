import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from matplotlib.patches import Polygon

# 全局参数
_kIndeterminateLinearDurationSecond = 1.8  # 1800ms
_kIndeterminateLinearDuration = _kIndeterminateLinearDurationSecond * 1000  # 转换为ms

# 时间轴（0~1800ms）
time_ms = np.linspace(0, _kIndeterminateLinearDuration, 1000)
time_normalized = time_ms / _kIndeterminateLinearDuration  # 归一化到[0,1]

# 定义贝塞尔曲线函数
def cubic_bezier_approx(t, a, b, c, d):
    u = 1 - t
    return 3 * u**2 * t * a + 3 * u * t**2 * c + t**3  # 忽略p0=0和p3=1的简化计算

def cubic_bezier_exact(t, curve):
    # 二分法求解精确贝塞尔值（简化版）
    low, high = 0.0, 1.0
    for _ in range(20):  # 迭代20次足够精确
        mid = (low + high) / 2
        estimate = 3 * (1-mid)**2 * mid * curve.a + 3 * (1-mid) * mid**2 * curve.c + mid**3
        if abs(t - estimate) < 0.001:
            return 3 * (1-mid)**2 * mid * curve.b + 3 * (1-mid) * mid**2 * curve.d + mid**3
        if estimate < t:
            low = mid
        else:
            high = mid
    return mid

# 定义曲线参数
class Cubic:
    def __init__(self, a, b, c, d):
        self.a, self.b, self.c, self.d = a, b, c, d

# 三种类型的曲线计算函数（统一为4参数接口）
def calculate_plain(t, begin, end, _=None):  # 添加冗余参数保持接口一致
    if t <= begin: return 0
    if t >= end: return 1
    return (t - begin) / (end - begin)

def calculate_approx(t, begin, end, curve):
    if t <= begin: return 0
    if t >= end: return 1
    progress = (t - begin) / (end - begin)
    return cubic_bezier_approx(progress, curve.a, curve.b, curve.c, curve.d)

def calculate_exact(t, begin, end, curve):
    if t <= begin: return 0
    if t >= end: return 1
    progress = (t - begin) / (end - begin)
    return cubic_bezier_exact(progress, curve)

# 计算所有曲线数据（优化版）
def generate_data(calculate_func, curves=None):
    data = {}
    params = [
        (0, 750, 0),          # line1_head
        (333, 1083, 1),       # line1_tail (333+750)
        (1000, 1567, 2),      # line2_head (1000+567)
        (1267, 1800, 3)       # line2_tail (1267+533)
    ]
    
    for key, (begin, end, curve_idx) in zip(
        ['line1_head', 'line1_tail', 'line2_head', 'line2_tail'],
        params
    ):
        curve = curves[curve_idx] if curves else None
        data[key] = [calculate_func(t, begin/_kIndeterminateLinearDuration, 
                                   end/_kIndeterminateLinearDuration, curve) 
                     for t in time_normalized]
    return data

# 生成三种类型的数据
plain_data = generate_data(calculate_plain)
approx_data = generate_data(calculate_approx, [
    Cubic(0.2, 0.0, 0.8, 1.0), Cubic(0.4, 0.0, 1.0, 1.0),
    Cubic(0.0, 0.0, 0.65, 1.0), Cubic(0.10, 0.0, 0.45, 1.0)
])
exact_data = generate_data(calculate_exact, [
    Cubic(0.2, 0.0, 0.8, 1.0), Cubic(0.4, 0.0, 1.0, 1.0),
    Cubic(0.0, 0.0, 0.65, 1.0), Cubic(0.10, 0.0, 0.45, 1.0)
])

# 修正后的绘制函数（修复where参数维度问题）
def plot_graph(ax, data, title):
    colors = {'line1': 'blue', 'line2': 'green'}
    for line in ['line1', 'line2']:
        # 绘制曲线
        ax.plot(time_ms, data[f'{line}_head'], color=colors[line], linestyle='-', 
                label=f'{line} Head (strokeEnd)')
        ax.plot(time_ms, data[f'{line}_tail'], color=colors[line], linestyle='--', 
                label=f'{line} Tail (strokeStart)')
        
        # 关键修复：显式转换为布尔数组，确保长度与time_ms一致
        where_condition = np.array(data[f'{line}_head']) > np.array(data[f'{line}_tail'])
        ax.fill_between(time_ms, 
                        data[f'{line}_head'], 
                        data[f'{line}_tail'], 
                        where=where_condition,
                        color=colors[line], alpha=0.2)
    
    ax.set(xlim=(0, 1800), ylim=(0, 1.1),
           xlabel='Time (ms)', ylabel='Progress', title=title)
    ax.legend()
    ax.grid(True)

# 创建图表
fig, axes = plt.subplots(3, 1, figsize=(10, 12), tight_layout=True)
titles = [
    'XMaterialLinearProgressAnimationPlain (Linear)',
    'XMaterialLinearProgressAnimationBazierApprox',
    'XMaterialLinearProgressAnimationBazierExact'
]

for ax, data, title in zip(axes, [plain_data, approx_data, exact_data], titles):
    plot_graph(ax, data, title)

plt.show()
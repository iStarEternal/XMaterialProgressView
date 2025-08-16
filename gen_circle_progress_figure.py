import numpy as np
import matplotlib.pyplot as plt

# 三次贝塞尔计算
def cubic_bezier_val(t, p0, p1, p2, p3):
    return (1-t)**3 * p0 + 3*(1-t)**2 * t * p1 + 3*(1-t) * t**2 * p2 + t**3 * p3

# 反解 x_target -> y_value
def cubic_bezier_y_for_x(x_target, p1x, p1y, p2x, p2y, eps=1e-5):
    if x_target <= 0: return 0
    if x_target >= 1: return 1
    low, high = 0.0, 1.0
    while low < high:
        mid = (low + high) / 2
        x_mid = cubic_bezier_val(mid, 0, p1x, p2x, 1)
        if abs(x_mid - x_target) < eps:
            return cubic_bezier_val(mid, 0, p1y, p2y, 1)
        if x_mid < x_target:
            low = mid
        else:
            high = mid
    return cubic_bezier_val((low + high) / 2, 0, p1y, p2y, 1)

# 动画参数（与 Swift 一致）
beginTime = 0.5
durationStart = 0.8 + beginTime  # 1.3
durationStop = 0.8
totalDuration = durationStart + beginTime  # Swift 动画组总时长 1.8
p1x, p1y, p2x, p2y = 0.4, 0.0, 0.2, 1.0

# 时间轴
time_ms = np.linspace(0, totalDuration * 1000, 1000)

lead = []   # strokeEnd
trail = []  # strokeStart

for t in time_ms / 1000:  # 秒
    # strokeEnd 从 0s 开始，持续 durationStop
    if t < durationStop:
        progress_end = cubic_bezier_y_for_x(t / durationStop, p1x, p1y, p2x, p2y)
    else:
        progress_end = 1
    lead.append(progress_end)

    # strokeStart 从 beginTime 开始，持续 durationStart
    if t < beginTime:
        progress_start = 0
    elif t < beginTime + durationStart:
        norm_t = (t - beginTime) / durationStart
        progress_start = cubic_bezier_y_for_x(norm_t, p1x, p1y, p2x, p2y)
    else:
        progress_start = 1
    trail.append(progress_start)

# 绘制
fig, ax = plt.subplots(figsize=(12, 6))
ax.plot(time_ms, lead, label="strokeEnd", color="green")
ax.plot(time_ms, trail, label="strokeStart", color="orange", linestyle="--")
ax.fill_between(time_ms, lead, trail, where=(np.array(lead) > np.array(trail)),
                color="green", alpha=0.2)

ax.axvline(beginTime*1000, color='gray', linestyle=':', alpha=0.5)
ax.text(beginTime*1000, 1.05, f'strokeStart beginTime={beginTime}s', ha='center', color='gray')
ax.set(xlabel="Time (ms)", ylabel="Progress", ylim=(0,1.2), xlim=(0, totalDuration*1000))
ax.legend()
ax.grid(True, linestyle='--', alpha=0.6)
plt.tight_layout()
plt.show()

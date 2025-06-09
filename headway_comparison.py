import numpy as np
import matplotlib.pyplot as plt

#Exponential decay function for cost
def f(x):
    return np.exp(-4/5 * x) * 10000

x_values = np.linspace(2, 11, 500)
y_values = f(x_values)
y_values_plus200 = y_values + 200  # New curve: original + 200
x_ticks = np.arange(3, 11, 1)  # Integer x-values from 3 to 10

plt.figure(figsize=(12, 7), constrained_layout=True)

# Plot both smooth curves
plt.plot(x_values, y_values, 
         label=r'Cost for paths without platform 26', 
         linewidth=4, 
         color="#EB1C23")  # DSB red

plt.plot(x_values, y_values_plus200, 
         label=r'Cost for paths with platform 26 (+200)', 
         linewidth=4, 
         color="darkblue")   

# Add X markers for BOTH curves
plt.scatter(x_ticks, f(x_ticks), 
            marker='x', 
            color='black', 
            s=100,
            linewidths=3,
            zorder=5)

plt.scatter(x_ticks, f(x_ticks) + 200, 
            marker='x', 
            color='black', 
            s=100,
            linewidths=3,
            zorder=5)

plt.title('Cost Functions With and Without Platform 26', pad=20, fontsize=20)
plt.xlabel('Headway (Minutes)', labelpad=10, fontsize=16)
plt.ylabel('Cost', labelpad=10, fontsize=16)
plt.xlim(2.5, 10.5)
plt.ylim(0, 1300)  
plt.xticks(x_ticks)
plt.xticks(fontsize=14)
plt.yticks(fontsize=14)
plt.grid(True, which='both', linestyle='--', alpha=0.7)

# Annotate both sets of points
for x in x_ticks:
    y = f(x)
    # Original curve annotations
    plt.text(x, y + 100, f'{y:.1f}', 
             ha='center', 
             va='bottom', 
             fontsize=12,
             bbox=dict(facecolor='white', alpha=0.8, edgecolor='none', boxstyle='round,pad=0.3'))
    
    # +200 curve annotations
    plt.text(x, y + 300, f'{y+200:.1f}', 
             ha='center', 
             va='bottom', 
             fontsize=12,
             bbox=dict(facecolor='white', alpha=0.8, edgecolor='none', boxstyle='round,pad=0.3'))

plt.legend(loc='upper right', 
           bbox_to_anchor=(1, 1), 
           borderaxespad=1.,
           fontsize=16,
           framealpha=1)

plt.savefig('headway_comparison.png', dpi=120, bbox_inches='tight')
plt.close()
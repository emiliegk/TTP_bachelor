import numpy as np
import matplotlib.pyplot as plt

def f(x):
    return np.exp(-4/5 * x) * 10000

x_values = np.linspace(2, 11, 500)
y_values = f(x_values)
<<<<<<< HEAD
y_values_plus200 = y_values + 200  # New curve: original + 200
=======
>>>>>>> main
x_ticks = np.arange(3, 11, 1)  # Integer x-values from 3 to 10

plt.figure(figsize=(12, 7), constrained_layout=True)

<<<<<<< HEAD
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

# Customize plot
plt.title('Cost Functions With and Without Platform 26', pad=20, fontsize=20)
plt.xlabel('Headway (Minutes)', labelpad=10, fontsize=16)
plt.ylabel('Cost', labelpad=10, fontsize=16)
plt.xlim(2.5, 10.5)
plt.ylim(0, 1300)  # Increased y-limit to accommodate +200 values
=======
# Plot the smooth curve
plt.plot(x_values, y_values, label=r'$f(x) = e^{-\frac{4}{5}x} \cdot 10000$', 
         linewidth=4, color='#C8102E')

# Add dots at each integer x-value
plt.scatter(x_ticks, f(x_ticks), marker = 'x', color='black', s=100, zorder=5)  # s=100 controls dot size

# Customize plot
plt.title('Cost Function for Headway', pad=20, fontsize=22)
plt.xlabel('Headway (Minutes)', labelpad=10, fontsize=16)
plt.ylabel('Cost', labelpad=10, fontsize=16)
plt.xlim(2.5, 10.5)
plt.ylim(0, 1100)
>>>>>>> main
plt.xticks(x_ticks)
plt.xticks(fontsize=14)
plt.yticks(fontsize=14)
plt.grid(True, which='both', linestyle='--', alpha=0.7)

<<<<<<< HEAD
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
=======
# Annotate each x-tick point
for x in x_ticks:
    y = f(x)
    plt.text(x, y + 100, f'{y:.1f}', ha='center', va='bottom', fontsize=14, 
             bbox=dict(facecolor='white', alpha=0.8, edgecolor='none', boxstyle='round,pad=0.2'))
>>>>>>> main

plt.legend(loc='upper right', 
           bbox_to_anchor=(1, 1), 
           borderaxespad=1.,
<<<<<<< HEAD
           fontsize=16,
           framealpha=1)

plt.savefig('headway_comparison.png', dpi=120, bbox_inches='tight')
=======
           fontsize=18,
           framealpha=1)

plt.savefig('headway.png', dpi=120, bbox_inches='tight')
>>>>>>> main
plt.close()
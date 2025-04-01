import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots

# Read and prepare data
df = pd.read_csv('train_schedule_with_paths.csv')
df['platform'] = df['platform'].astype(str)
df.loc[df['platform'] == '9', 'platform'] = '26'
df['platform'] = 'Platform ' + df['platform']

# Define the desired platform order
platform_labels_ordered = [f'Platform {i}' for i in range(1, 9)] + ['Platform 26']

# Convert times
today = pd.to_datetime('today').strftime('%Y-%m-%d')
df['arrival_time'] = pd.to_datetime(today + ' ' + df['arrival_time'])
df['departure_time'] = pd.to_datetime(today + ' ' + df['departure_time'])

# Define time intervals
time_ranges = [
    ('05:55:00', '06:55:00'),
    ('06:55:00', '07:55:00'),
    ('07:55:00', '09:05:00')
]

# Define a consistent start time for the grid lines (e.g., 05:55:00)
grid_start_time = pd.to_datetime(today + ' 05:55:00')
five_minutes_ms = 5 * 60 * 1000

# Create subplots
fig = make_subplots(
    rows=3, cols=1,
    subplot_titles=["5:55-6:55", "6:55-7:55", "7:55-9:05"],
    vertical_spacing=0.1,
    shared_yaxes=True,
    row_heights=[0.33, 0.33, 0.34]
)

# Create a color mapping for directions
direction_colors = {
    'mod_vest': '#1f77b4',
    'mod_kn': '#ff7f0e',
    'vender': '#2ca02c'
}

# Create a set to track which directions we've already added to legend
added_directions = set()

# Create each timeline segment
for i, (start, end) in enumerate(time_ranges, 1):
    time_start_range = pd.to_datetime(today + ' ' + start)
    time_end_range = pd.to_datetime(today + ' ' + end)
    df_range = df[(df['arrival_time'] <= time_end_range) & (df['departure_time'] >= time_start_range)].copy()

    # Add vertical lines
    current_time = grid_start_time
    while current_time <= time_end_range + pd.Timedelta(minutes=2):
        if current_time >= time_start_range:
            linewidth = 0.5
            if current_time.minute % 5 == 0:
                linewidth = 1.0  # Thicker line at 5-minute marks

            fig.add_trace(go.Scatter(
                x=[current_time, current_time],
                y=[-0.5, len(platform_labels_ordered) - 0.5],
                mode='lines',
                line=dict(color="white", width=linewidth),
                showlegend=False,
                name=f'vline_{current_time.strftime("%H:%M")}'
            ), row=i, col=1)
        current_time += pd.Timedelta(minutes=1)

    # Add Gantt bars
    for _, row in df_range.iterrows():
        mid_time = row['arrival_time'] + (row['departure_time'] - row['arrival_time'])/2
        y_pos = platform_labels_ordered.index(row['platform'])
        y_thickness = 0.3
        train_label = f"{row['train_id']}"
        text_color = 'black'
        if train_label.endswith('*'):
            text_color = 'red'

        show_legend = (i == 1) and (row['direction'] not in added_directions)
        if show_legend:
            added_directions.add(row['direction'])

        fig.add_trace(go.Scatter(
            x=[row['arrival_time'], row['departure_time'], row['departure_time'], row['arrival_time'], row['arrival_time']],
            y=[y_pos+y_thickness, y_pos+y_thickness, y_pos-y_thickness, y_pos-y_thickness, y_pos+y_thickness],
            fill="toself",
            fillcolor=direction_colors[row['direction']],
            line=dict(color=direction_colors[row['direction']], width=0),
            mode='lines',
            name=row['direction'].replace('mod_vest', 'Westbound').replace('mod_kn', 'Northbound (KN)').replace('vender', 'Turning'),
            text=train_label,
            hoverinfo='text',
            showlegend=show_legend,
            legendgroup=row['direction'],
        ), row=i, col=1)

        fig.add_annotation(
            x=mid_time,
            y=y_pos,
            text=train_label,
            showarrow=False,
            font=dict(color=text_color, size=10),
            row=i, col=1
        )

    # Set axes properties (keep dtick for 5 minutes for labels)
    fig.update_xaxes(
        range=[time_start_range, time_end_range],
        tickformat='%H:%M',
        row=i, col=1,
        tick0=grid_start_time,
        dtick=five_minutes_ms  # Keep dtick at 5 minutes for labels
    )
    fig.update_yaxes(
        tickvals=list(range(len(platform_labels_ordered))),
        ticktext=platform_labels_ordered,
        range=[-0.5, len(platform_labels_ordered)-0.5],
        categoryorder='array',
        categoryarray=platform_labels_ordered,
        row=i, col=1,
        tickangle=30
    )

# Update layout
fig.update_layout(
    title_text="Train Platform Occupancy Schedule",
    title_x=0.5,
    height=1200,
    legend_title_text="Direction",
    margin=dict(l=150, r=50, b=50, t=100),
    hovermode='closest'
)

fig.write_image("train_occupancy_gantt_2min_lines_5min_labels.png", scale=2)
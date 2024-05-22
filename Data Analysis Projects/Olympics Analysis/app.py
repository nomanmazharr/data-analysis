import streamlit as st
import pandas as pd
import helper
import plotly.express as px
import matplotlib.pyplot as plt
import seaborn as sns
import plotly.figure_factory as ff

#
olympics = pd.read_csv('athlete_events.csv')
origin = pd.read_csv('noc_regions.csv')
#
# # Doing some basic preprocessing on the data
df = pd.merge(olympics, origin, on='NOC', how='left')
df = df.drop_duplicates()
df = pd.concat((df, pd.get_dummies(df['Medal'])), axis=1)


st.sidebar.title('Olympics Analysis')
user_menu = st.sidebar.radio(
    'Elect an option',
    ('Medal Count', 'Player-by-Player Analysis', 'Regional Analysis', 'Comprehensive Analysis')
)

if user_menu == 'Medal Count':
    st.title(':red[How Medals Are Awarded: Understanding the Prestigious Honor]')
    st.text('Select from the dropdown menu below the type of analysis you would like')
    year, country = helper.country_year(df)
    selected_year = st.selectbox(
        'Select year',
        year
    )

    selected_region = st.selectbox(
        'Select Country',
        country
    )

    medal_count = helper.medal(df, selected_year, selected_region)
    if selected_year == 'Overall' and selected_region == 'Overall':
        st.title('Overall Analysis')
    if selected_year != 'Overall' and selected_region == 'Overall':
        st.title("Medal Count in " + str(selected_year) + " Olympics")
    if selected_year == 'Overall' and selected_region != 'Overall':
        st.title(selected_region + " overall performance")
    if selected_year != 'Overall' and selected_region != 'Overall':
        st.title(selected_region + " performance in " + str(selected_year) + " Olympics")
    st.table(medal_count)

if user_menu == 'Player-by-Player Analysis':

    athlete_df = df.drop_duplicates(subset=['Name', 'region'])

    x1 = athlete_df['Age'].dropna()
    
    
    
    x2 = athlete_df[athlete_df['Medal'] == 'Gold']['Age'].dropna()
    x3 = athlete_df[athlete_df['Medal'] == 'Silver']['Age'].dropna()
    x4 = athlete_df[athlete_df['Medal'] == 'Bronze']['Age'].dropna()

    fig = ff.create_distplot([x1, x2, x3, x4], ['Overall Age', 'Gold Medalist', 'Silver Medalist', 'Bronze Medalist'],show_hist=False, show_rug=False)
    fig.update_layout(autosize=False,width=1000,height=600)
    st.title(":blue[Distribution of Age]")
    st.plotly_chart(fig)

    x = []
    name = []
    famous_sports = ['Basketball', 'Judo', 'Football', 'Tug-Of-War', 'Athletics',
                     'Swimming', 'Badminton', 'Sailing', 'Gymnastics',
                     'Art Competitions', 'Handball', 'Weightlifting', 'Wrestling',
                     'Water Polo', 'Hockey', 'Rowing', 'Fencing',
                     'Shooting', 'Boxing', 'Taekwondo', 'Cycling', 'Diving', 'Canoeing',
                     'Tennis', 'Golf', 'Softball', 'Archery',
                     'Volleyball', 'Synchronized Swimming', 'Table Tennis', 'Baseball',
                     'Rhythmic Gymnastics', 'Rugby Sevens',
                     'Beach Volleyball', 'Triathlon', 'Rugby', 'Polo', 'Ice Hockey']
    for sport in famous_sports:
        temp_df = athlete_df[athlete_df['Sport'] == sport]
        x.append(temp_df[temp_df['Medal'] == 'Gold']['Age'].dropna())
        name.append(sport)

    st.title(":blue[Trends in Men Vs Women Participation Over the Years]")
    final = helper.men_vs_women(df)
    fig = px.line(final, x="Year", y=["Male", "Female"])
    fig.update_layout(autosize=False, width=1000, height=600)
    st.plotly_chart(fig)

    fig = ff.create_distplot(x, name, show_hist=False, show_rug=False)
    fig.update_layout(autosize=False, width=1000, height=600)
    st.title(":blue[Relationship between Age and Winning Gold Medals in Sports]")
    st.plotly_chart(fig)

    sport_list = df['Sport'].unique().tolist()
    sport_list.sort()
    sport_list.insert(0, 'Overall')

    st.title(':blue[Height Vs Weight]')
    selected_sport = st.selectbox('Select a Sport', sport_list)
    temp_df = helper.weight_v_height(df,selected_sport)
    fig,ax = plt.subplots()
    ax = sns.scatterplot(x=temp_df['Weight'], y=temp_df['Height'], hue=temp_df['Medal'],style=temp_df['Sex'],s=60)
    st.pyplot(fig)

if user_menu == 'Comprehensive Analysis':
    editions = df['Year'].unique().shape[0] - 1
    cities = df['City'].unique().shape[0]
    sports = df['Sport'].unique().shape[0]
    events = df['Event'].unique().shape[0]
    athletes = df['Name'].unique().shape[0]
    nations = df['region'].unique().shape[0]

    st.title("Explore stats and facts about Olympics")
    col1, col2 = st.columns(2)
    with col1:
        st.header("Total Countries")
        st.title(nations)
    with col2:
        st.header("Total hosts")
        st.title(cities)
    col1, col2 = st.columns(2)
    with col1:
        st.header("No of Editions")
        st.title(editions)
    with col2:
        st.header('Sports')
        st.title(sports)
    col1, col2 = st.columns(2)
    with col1:
        st.header("Events")
        st.title(events)
    with col2:
        st.header("Athletes")
        st.title(athletes)

    events_over_time = helper.data_over_time(df, 'Event')
    fig = px.line(events_over_time, x="Edition", y="Event")
    st.title(":blue[Evolution of Olympic Events]")
    st.plotly_chart(fig)

    nations_over_time = helper.data_over_time(df, 'region')
    fig = px.line(nations_over_time, x="Edition", y="region")
    st.title(":blue[Historical Look at Nations Participating in the Olympics]")
    st.plotly_chart(fig)

    athlete_over_time = helper.data_over_time(df, 'Name')
    fig = px.line(athlete_over_time, x="Edition", y="Name")
    st.title(":blue[Analyzing Evolution of Olympic Athletes Over Time]")
    st.plotly_chart(fig)

    st.title(":blue[Growth of Olympic Sports: Tracing the Evolution of Events Over Time]")
    fig, ax = plt.subplots(figsize=(20, 20))
    x = df.drop_duplicates(['Year', 'Sport', 'Event'])
    ax = sns.heatmap(x.pivot_table(index='Sport', columns='Year', values='Event', aggfunc='count').fillna(0).astype('int'),
                     annot=True)
    st.pyplot(fig)

    st.title("Most successful Athletes")
    sport_list = df['Sport'].unique().tolist()
    sport_list.sort()
    sport_list.insert(0, 'Overall')

    selected_sport = st.selectbox('Select a Sport', sport_list)
    x = helper.most_successful(df, selected_sport)
    st.table(x)

if user_menu == 'Regional Analysis':

    st.title('Country-wise Analysis')

    country_list = df['region'].dropna().unique().tolist()
    country_list.sort()

    selected_country = st.selectbox('Select a Country', country_list)

    country_df = helper.yearwise_medal_tally(df, selected_country)
    fig = px.line(country_df, x="Year", y="Medal")
    st.title(selected_country + " Medal Tally over the years")
    st.plotly_chart(fig)

    try:
        pt = helper.country_event_heatmap(df, selected_country)
        fig, ax = plt.subplots(figsize=(20, 20))
        ax = sns.heatmap(pt, annot=True)
        st.pyplot(fig)
    except Exception:
        st.title(selected_country + ' has not won any medals')

    st.title("Top 10 athletes of " + selected_country)
    top10_df = helper.most_successful_countrywise(df, selected_country)
    st.table(top10_df)



#Connect to Azure
###add path for dbconnect
import sys
sys.path.append('C:\\Users\\zfang\\Desktop\\Zed')

###import db connection
from dbconnect import cnxn1,cnxn2

#############################################################################################################

### Date Input
print ('The first date is 2017-11-02')
print ('The report will include last 7 days from max(input_date)')

### Read SQL query
query = '''
select * from Fact.prisma_roll_all_v2
''' 

query = query.format_map(vars())
print (query)

import pandas as pd
df = pd.read_sql(query,cnxn1)

# Change first letter of each column to capital
df.columns = [col.title() for col in df.columns]

### Select Advertiser to Output
print ('list of clients:\n{}'.format(df.Advertiser_Name.unique()))

#selected_advertisers = input ("Advertisers: ")
#if selected_advertisers.upper() == 'ALL':
#    pass
#else:
#    df = df[df.Advertiser_Name.str.match(selected_advertisers.upper())]   


#############################################################################################################
### In-Depth View
### Advertiser | Code | Publisher | Product | Product Code | Estimate (Campaign) | User | Cost
df_pivot = df.pivot_table(values='Cost',columns='Input_Date',
                              index=['Advertiser_Name', 'Advertiser_Code', 'Placement_Site', 'Product_Name',
                                     'Product_Code', 'Estimate_Code', 'Month', 'Placement_User' ])

df_pivot.columns.name = ''
df_pivot.reset_index(inplace=True)

# Fill NaN with former date data
df_pivot.loc[:,[col for col in df_pivot.columns if '-' in str(col)]]= df_pivot.loc[:,[col for col in df_pivot.columns if '-' in str(col)]].fillna(method='ffill',axis=1)

#############################################################################################################
### Base View
### Advertiser | Code | Month | User | Cost
base = df_pivot.groupby(['Advertiser_Name','Advertiser_Code','Month','Placement_User'])[df_pivot.columns[df_pivot.dtypes == 'float64'].tolist()].sum()
base.reset_index(inplace=True)
# Last 7 days
base_selected = pd.concat([base.iloc[:,0:4],base.iloc[:,-7:]],axis=1)


### In-depth View
in_depth = df_pivot
# Last 7 days
in_depth_selected = pd.concat([in_depth.iloc[:,0:8],in_depth.iloc[:,-7:]],axis=1)


#Alert
base_selected['Have_Change'] = base_selected.iloc[:,-1]!=base_selected.iloc[:,-2]
df_change = base_selected[['Advertiser_Name','Month','Placement_User']][base_selected.Have_Change==True]

#############################################################################################################
## Connect and Write to FTP
from FTPCONNECT import ftp

ftp.cwd('/')

writer = pd.ExcelWriter('Prisma_Historical_{}.xlsx'.format(str(df.Input_Date.max())))

##The first Sheet
workbook = writer.book
worksheet = workbook.add_worksheet(name='Note')

notice1 = 'The first date is 2017-11-02'
notice2 = 'The report will include last 7 days from today'

format = workbook.add_format()
format.set_font_size(16)
worksheet.write_string(1,1,notice1,format)
worksheet.write_string(2,1,notice2,format)

##The Second, Third and Fourth Sheet
df_change.to_excel(writer,'Change_List',index=False)
base_selected.to_excel(writer,'Base_View',index=False)
in_depth_selected.to_excel(writer,'In_Depth_View',index=False)

writer.close()

##Write into FTP
filename = 'Prisma_Historical_{}.xlsx'.format(str(df.Input_Date.max()))
f = open(filename, 'rb')
ftp.storbinary('STOR %s' %filename, f)
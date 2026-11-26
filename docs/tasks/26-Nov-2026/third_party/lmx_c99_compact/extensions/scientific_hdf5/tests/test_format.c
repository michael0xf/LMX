/* Generates every fixture locally. Covers core format and every HL C module. */
#include <hdf5.h>
#include <hdf5_hl.h>
#include <stdio.h>
#include <string.h>
#define CHECK(x) do { if (!(x)) { fprintf(stderr,"HDF5 check failed at %d: %s\n",__LINE__,#x); return 1; } } while(0)
typedef struct { int id; double value; } Row;
int main(void) {
    const char *path="lmx-hdf5-format.h5"; hid_t file,space,dcpl,dataset,scale,packets,type;
    hsize_t dims[2]={2,3}, maximum[2]={H5S_UNLIMITED,3}, chunk[2]={1,3}, now[2], scale_dim[1]={3}, count;
    double input[6]={1.25,2.5,3.75,4.5,5.25,6.0}, extra[3]={7.0,8.5,9.75}, result[9];
    int scale_values[3]={10,20,30}, packet_values[3]={41,42,43}, packet_read[3];
    const unsigned char pixels[12]={255,0,0,0,255,0,0,0,255,255,255,255}; unsigned char image[12];
    Row rows[2]={{1,1.5},{2,2.75}}, read_rows[2];
    const char *fields[2]={"id","value"}; size_t offsets[2]={HOFFSET(Row,id),HOFFSET(Row,value)};
    size_t sizes[2]={sizeof(int),sizeof(double)}; hid_t types[2]; char attribute[32], type_text[512]; size_t text_size=sizeof type_text;
    int i;
    CHECK(H5open()>=0); CHECK(H5Zfilter_avail(H5Z_FILTER_DEFLATE)>0);
    file=H5Fcreate(path,H5F_ACC_TRUNC,H5P_DEFAULT,H5P_DEFAULT); CHECK(file>=0);
    space=H5Screate_simple(2,dims,maximum); CHECK(space>=0); dcpl=H5Pcreate(H5P_DATASET_CREATE); CHECK(dcpl>=0);
    CHECK(H5Pset_chunk(dcpl,2,chunk)>=0); CHECK(H5Pset_shuffle(dcpl)>=0); CHECK(H5Pset_deflate(dcpl,6)>=0); CHECK(H5Pset_fletcher32(dcpl)>=0);
    dataset=H5Dcreate2(file,"measurements",H5T_IEEE_F64LE,space,H5P_DEFAULT,dcpl,H5P_DEFAULT); CHECK(dataset>=0);
    CHECK(H5Dwrite(dataset,H5T_NATIVE_DOUBLE,H5S_ALL,H5S_ALL,H5P_DEFAULT,input)>=0);
    CHECK(H5DOappend(dataset,H5P_DEFAULT,0,1,H5T_NATIVE_DOUBLE,extra)>=0);
    CHECK(H5LDget_dset_dims(dataset,now)>=0 && now[0]==3 && now[1]==3);
    CHECK(H5LTset_attribute_string(file,"measurements","unit","K")>=0);
    CHECK(H5LTmake_dataset_int(file,"column",1,scale_dim,scale_values)>=0);
    scale=H5Dopen2(file,"column",H5P_DEFAULT); CHECK(scale>=0); CHECK(H5DSset_scale(scale,"column index")>=0);
    CHECK(H5DSattach_scale(dataset,scale,1)>=0 && H5DSis_attached(dataset,scale,1)>0);
    CHECK(H5Dclose(scale)>=0); CHECK(H5Dclose(dataset)>=0); CHECK(H5Pclose(dcpl)>=0); CHECK(H5Sclose(space)>=0);
    CHECK(H5IMmake_image_24bit(file,"image",2,2,"INTERLACE_PIXEL",pixels)>=0);
    types[0]=H5T_NATIVE_INT; types[1]=H5T_NATIVE_DOUBLE;
    CHECK(H5TBmake_table("records",file,"table",2,2,sizeof(Row),fields,offsets,types,2,NULL,0,rows)>=0);
    packets=H5PTcreate(file,"packets",H5T_NATIVE_INT,4,H5P_DEFAULT); CHECK(packets>=0);
    CHECK(H5PTappend(packets,3,packet_values)>=0); CHECK(H5PTget_num_packets(packets,&count)>=0 && count==3); CHECK(H5PTclose(packets)>=0);
    type=H5LTtext_to_dtype("H5T_ARRAY { [2][3] H5T_STD_I32LE }",H5LT_DDL); CHECK(type>=0 && H5Tget_class(type)==H5T_ARRAY);
    CHECK(H5Tget_array_dims2(type,now)==2 && now[0]==2 && now[1]==3);
    CHECK(H5LTdtype_to_text(type,type_text,H5LT_DDL,&text_size)>=0 && strstr(type_text,"H5T_ARRAY")!=NULL); CHECK(H5Tclose(type)>=0);
    CHECK(H5Fclose(file)>=0);
    file=H5Fopen(path,H5F_ACC_RDONLY,H5P_DEFAULT); CHECK(file>=0);
    CHECK(H5LTread_dataset_double(file,"measurements",result)>=0);
    for(i=0;i<6;++i) CHECK(result[i]==input[i]); for(i=0;i<3;++i) CHECK(result[i+6]==extra[i]);
    CHECK(H5LTget_attribute_string(file,"measurements","unit",attribute)>=0 && strcmp(attribute,"K")==0);
    CHECK(H5IMread_image(file,"image",image)>=0 && memcmp(image,pixels,sizeof pixels)==0);
    CHECK(H5TBread_table(file,"table",sizeof(Row),offsets,sizes,read_rows)>=0);
    for(i=0;i<2;++i) CHECK(read_rows[i].id==rows[i].id && read_rows[i].value==rows[i].value);
    packets=H5PTopen(file,"packets"); CHECK(packets>=0); CHECK(H5PTread_packets(packets,0,3,packet_read)>=0);
    CHECK(memcmp(packet_read,packet_values,sizeof packet_values)==0); CHECK(H5PTclose(packets)>=0);
    CHECK(H5Fclose(file)>=0); CHECK(H5close()>=0); CHECK(remove(path)==0);
    puts("HDF5 compressed format + LT/DO/LD/DS/IM/TB/PT + dtype parser OK"); return 0;
}

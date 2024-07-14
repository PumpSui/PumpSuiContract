module suifund::svg {
    const SVG_part1: vector<u8> = b"data:image/svg+xml,%3Csvg width='500' height='697' xmlns='http://www.w3.org/2000/svg'%3E%3Cimage href='https://elrywej3npyqs2pktpedyzoro2namlwnzmurrsmobgnkhzu22ixa.arweave.net/IuOLETtr8Qlp6pvIPGXRdpoGLs3LKRjJjgmao-aa0i4' height='697' width='500'/%3E%3Cimage href='https://d5qfgbh4cbg4nf4eakrchrx5hy4y5rszmjhprzjke4xbz5zecquq.arweave.net/H2BTBPwQTcaXhAKiI8b9PjmOxlliTvjlKicuHPckFCk' x='50' y='40' height='100'/%3E%3Cimage href='";
    const SVG_part2: vector<u8> = b"' x='43.5' y='84' height='300' width='400' preserveAspectRatio='none'/%3E%3Ctext y='475' font-family=''Arial',sans-serif' font-size='24' fill='%23011829' text-anchor='left' dominant-baseline='central'%3E%3Ctspan x='165' dy='0em'%3E";
    const SVG_part3: vector<u8> = b"%3C/tspan%3E %3Ctspan x='165' dy='1.5em'%3E";
    const SVG_part4: vector<u8> = b"%3C/tspan%3E%3C/text%3E%3Cimage href='https://sw5uhptwpmr3rabtcnw26ck3t6r5xvt3m52gigsojxsve3sq5koa.arweave.net/lbtDvnZ7I7iAMxNtrwlbn6Pb1ntndGQaTk3lUm5Q6pw' x='140' y='480' height='200' width='400'/%3E%3C/svg%3E";

    public(package) fun generateSVG(image_url: vector<u8>, project_name: vector<u8>, amount: vector<u8>): vector<u8>{
        let mut image_data = SVG_part1;
        vector::append(&mut image_data, image_url);
        vector::append(&mut image_data, SVG_part2);
        vector::append(&mut image_data, project_name);
        vector::append(&mut image_data, SVG_part3);
        vector::append(&mut image_data, amount);
        vector::append(&mut image_data, SVG_part4);

        image_data
    }
}
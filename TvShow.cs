using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GetTvShowTotalLength
{
    public record class TvShow(int id, string name, DateOnly? premiered);
}
